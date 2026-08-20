import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cv_document.dart';
import '../state/cv_library.dart';
import '../theme/design_tokens.dart';
import 'profile_screen.dart';
import 'templates_screen.dart';
import '../widgets/states.dart';

/// « Mes CV » — `maquettes/04_mes-cv.jpg`.
///
/// Refonte complète du tableau de bord violet. Trois écarts structurels avec
/// le portage, au-delà du style :
///
/// * **Cinq onglets deviennent trois** — Mes CV, Modèles, Profil. Les deux
///   supprimés (Accueil, IA) ne menaient nulle part.
/// * **La liste est groupée par poste visé**, plus filtrée par statut. Un même
///   parcours donne plusieurs CV, un par poste ciblé : c'est l'organisation
///   que propose la maquette, et elle rend les filtres inutiles.
/// * **Le bouton de création flotte** en bas à droite au lieu d'occuper le
///   centre de la barre d'onglets.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenEditor,
    required this.onCreateNew,
    required this.onSignOut,
    required this.onReplayOnboarding,
  });

  final ValueChanged<String> onOpenEditor;
  final VoidCallback onCreateNew;
  final VoidCallback onSignOut;
  final VoidCallback onReplayOnboarding;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0;

  /// Groupe les documents par poste visé, brouillons en dernier — c'est
  /// l'ordre de la maquette, et le seul qui ait du sens : un brouillon n'a pas
  /// encore de poste à viser.
  List<(String, List<CvDocument>)> _grouped(List<CvDocument> docs) {
    final groups = <String, List<CvDocument>>{};
    for (final d in docs) {
      groups.putIfAbsent(d.group, () => []).add(d);
    }

    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == 'BROUILLON') return 1;
        if (b == 'BROUILLON') return -1;
        return a.compareTo(b);
      });

    return [for (final k in keys) (k, groups[k]!)];
  }

  /// Supprime un document, en laissant le temps de se raviser : une
  /// suppression sans retour arrière est le genre de geste qu'on regrette
  /// une fois sur deux.
  void _delete(CvDocument doc) {
    final library = context.read<CvLibrary>();
    library.remove(doc.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('« ${doc.title} » supprimé'),
          action: SnackBarAction(
            label: 'Annuler',
            onPressed: () => library.restore(doc),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<CvLibrary>();
    final docs = library.sortedByDate;

    return Scaffold(
      backgroundColor: Paper.bg,
      body: SafeArea(
        bottom: false,
        child: switch (_tab) {
          1 => const TemplatesScreen(),
          2 => ProfileScreen(
              onSignOut: widget.onSignOut,
              onReplayOnboarding: widget.onReplayOnboarding,
              onOpenTemplates: () => setState(() => _tab = 1),
            ),
          _ => _Library(
              documents: docs,
              groups: _grouped(docs),
              onOpen: widget.onOpenEditor,
              onCreateNew: widget.onCreateNew,
              onDelete: _delete,
            ),
        },
      ),
      bottomNavigationBar: _BottomNav(
        active: _tab,
        onChange: (i) => setState(() => _tab = i),
      ),
    );
  }
}

// ── Onglet « Mes CV » ────────────────────────────────────────────────────

class _Library extends StatelessWidget {
  const _Library({
    required this.documents,
    required this.groups,
    required this.onOpen,
    required this.onCreateNew,
    required this.onDelete,
  });

  final List<CvDocument> documents;
  final List<(String, List<CvDocument>)> groups;
  final ValueChanged<String> onOpen;
  final VoidCallback onCreateNew;
  final ValueChanged<CvDocument> onDelete;

  @override
  Widget build(BuildContext context) {
    final roleCount = groups.where((g) => g.$1 != 'BROUILLON').length;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 120),
          children: [
            // ── En-tête ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                Space.md,
                Space.xl,
                Space.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Mes CV', style: Serif.title),
                        const SizedBox(height: Space.xs),
                        Text(
                          '${documents.length} DOCUMENT'
                          '${documents.length > 1 ? "S" : ""} · '
                          '$roleCount POSTE${roleCount > 1 ? "S" : ""} VISÉ'
                          '${roleCount > 1 ? "S" : ""}',
                          style: Mono.overline,
                        ),
                      ],
                    ),
                  ),
                  const _SearchButton(),
                ],
              ),
            ),

            const Divider(color: Paper.rule, height: 1),

            // ── Groupes ───────────────────────────────────────
            for (final (label, items) in groups) ...[
              _GroupHeader(label: label, count: items.length),
              for (final doc in items) ...[
                // Le balayage n'apparaît pas dans la maquette, qui ne montre
                // qu'un chevron. Il n'en change pas l'aspect, et sans lui
                // rien ne peut supprimer un document : `CvLibrary.remove`
                // n'était appelé de nulle part, et l'état vide de la
                // maquette 09 restait inatteignable.
                Dismissible(
                  key: ValueKey(doc.id),
                  direction: DismissDirection.endToStart,
                  background: const _DeleteBackground(),
                  onDismissed: (_) => onDelete(doc),
                  child: _DocumentRow(doc: doc, onTap: () => onOpen(doc.id)),
                ),
                const Divider(color: Paper.rule, height: 1, indent: Space.xl),
              ],
            ],

            if (documents.isEmpty)
              EmptyState(
                title: "Aucun CV pour l'instant",
                message: "Décrivez votre parcours, l'IA s'occupe de la mise "
                    'en forme.',
                actionLabel: 'Créer mon premier CV',
                onAction: onCreateNew,
              ),
          ],
        ),

        // ── Bouton de création ────────────────────────────────
        //
        // Masqué quand la bibliothèque est vide : l'état de la maquette 09
        // porte déjà l'unique action, et deux boutons pour la même chose
        // en affaibliraient un.
        if (documents.isNotEmpty)
          Positioned(
            right: Space.xl,
            bottom: Space.xl,
            child: _NewCvButton(onTap: onCreateNew),
          ),
      ],
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: Border.all(color: Paper.rule),
      ),
      child: const Icon(Icons.search, size: 20, color: Pen.primary),
    );
  }
}

/// En-tête de groupe : libellé rouge, filet qui court jusqu'au compteur.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final isDraft = label == 'BROUILLON';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.xl,
        Space.xl,
        Space.xl,
        Space.md,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: isDraft ? Mono.overline : Mono.overlineAccent,
          ),
          const SizedBox(width: Space.md),
          const Expanded(child: Divider(color: Paper.rule, height: 1)),
          const SizedBox(width: Space.md),
          Text('$count', style: Mono.overline),
        ],
      ),
    );
  }
}

/// Ligne de document : vignette, intitulé, métadonnée, score ATS, chevron.
class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.doc, required this.onTap});

  final CvDocument doc;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDraft = doc.isDraft;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xl,
          vertical: Space.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Thumbnail(isDraft: isDraft),
            const SizedBox(width: Space.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Sans.itemTitle.copyWith(
                      color: isDraft ? Pen.secondary : Pen.primary,
                    ),
                  ),
                  const SizedBox(height: Space.xs),
                  Text(
                    isDraft
                        ? 'Commencé ${doc.editedLabel.toLowerCase()} · '
                            '${_sectionsFilled(doc)} sections sur 6'
                        : 'Modifié ${doc.editedLabel.toLowerCase()} · '
                            'modèle ${doc.templateName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Mono.meta,
                  ),
                  const SizedBox(height: Space.md),
                  if (isDraft)
                    const _Badge(
                      'À TERMINER',
                      fg: Status.warnFg,
                      bg: Status.warnBg,
                    )
                  else
                    _AtsScore(score: doc.score),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: Space.sm, left: Space.sm),
              child: Icon(
                Icons.chevron_right,
                size: 22,
                color: Pen.faint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Nombre de sections renseignées sur les six que compte un CV.
  int _sectionsFilled(CvDocument d) {
    final info = d.data.personalInfo;
    var n = 0;
    if (info.fullName.trim().isNotEmpty) n++;
    if (info.summary.trim().isNotEmpty) n++;
    if (d.data.experiences.isNotEmpty) n++;
    if (d.data.educations.isNotEmpty) n++;
    if (d.data.skills.isNotEmpty) n++;
    if (d.data.languages.isNotEmpty) n++;
    return n;
  }
}

/// Vignette de CV — une feuille miniature, pas une icône. Le trait rouge en
/// haut rappelle l'accent du document réel.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.isDraft});

  final bool isDraft;

  @override
  Widget build(BuildContext context) {
    if (isDraft) {
      return Container(
        width: 44,
        height: 52,
        padding: const EdgeInsets.all(Space.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.xs),
          border: Border.all(
            color: Paper.ruleStrong,
            style: BorderStyle.solid,
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(width: 20, height: 3, color: Paper.ruleStrong),
        ),
      );
    }

    return Container(
      width: 44,
      height: 52,
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.xs),
        border: Border.all(color: Paper.rule),
        boxShadow: Shadow.sheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 22, height: 2.5, color: Accent.redLine),
          const SizedBox(height: Space.xs),
          for (final w in [1.0, 0.85, 1.0, 0.7]) ...[
            FractionallySizedBox(
              widthFactor: w,
              alignment: Alignment.centerLeft,
              child: Container(height: 2, color: Paper.rule),
            ),
            const SizedBox(height: 3),
          ],
        ],
      ),
    );
  }
}

/// Score ATS : le chiffre, une barre, l'étiquette. Pas d'anneau — la maquette
/// aligne tout sur une ligne de base, dans l'esprit d'un tableau.
class _AtsScore extends StatelessWidget {
  const _AtsScore({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$score', style: Mono.score),
        const SizedBox(width: Space.sm),
        SizedBox(
          width: 88,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(Radii.xs),
            child: Stack(
              children: [
                const Positioned.fill(child: ColoredBox(color: Paper.rule)),
                Positioned.fill(
                  child: FractionallySizedBox(
                    widthFactor: (score / 100).clamp(0.0, 1.0),
                    alignment: Alignment.centerLeft,
                    child: const ColoredBox(color: Accent.red),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: Space.sm),
        Text('ATS', style: Mono.overline.copyWith(letterSpacing: 1.2)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {required this.fg, required this.bg});

  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Radii.xs),
      ),
      child: Text(label, style: Mono.badge.copyWith(color: fg)),
    );
  }
}

class _NewCvButton extends StatelessWidget {
  const _NewCvButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Accent.red,
      borderRadius: BorderRadius.circular(Radii.md),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Space.xl,
            vertical: Space.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.md),
            boxShadow: Shadow.floating,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 20, color: Colors.white),
              const SizedBox(width: Space.sm),
              Text(
                'Nouveau CV',
                style: Sans.button.copyWith(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Barre d'onglets ──────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.active, required this.onChange});

  final int active;
  final ValueChanged<int> onChange;

  static const _items = [
    (Icons.description_outlined, 'MES CV'),
    (Icons.dashboard_outlined, 'MODÈLES'),
    (Icons.person_outline, 'PROFIL'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Paper.bg,
        border: Border(top: BorderSide(color: Paper.rule)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              for (final (i, item) in _items.indexed)
                Expanded(
                  child: InkWell(
                    onTap: () => onChange(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$1,
                          size: 22,
                          color: i == active ? Accent.red : Pen.muted,
                        ),
                        const SizedBox(height: Space.sm),
                        Text(
                          item.$2,
                          style: Mono.overline.copyWith(
                            fontSize: 9.5,
                            color: i == active ? Accent.red : Pen.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fond révélé par le balayage de suppression.
class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Accent.redWash,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Space.xl),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('SUPPRIMER', style: Mono.overlineAccent),
          SizedBox(width: Space.md),
          Icon(Icons.delete_outline, size: 20, color: Accent.red),
        ],
      ),
    );
  }
}
