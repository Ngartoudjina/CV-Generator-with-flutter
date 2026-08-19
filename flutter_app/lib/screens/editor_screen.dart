import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cv_data.dart';
import '../state/cv_library.dart';
import '../state/cv_model.dart';
import '../theme/design_tokens.dart';
import '../widgets/cv_sheet.dart';
import '../widgets/editor_fields.dart';
import '../models/cv_section.dart';

/// Éditeur — `maquettes/05_editeur.jpg`.
///
/// Change de nature, pas seulement d'apparence. Le portage était un
/// formulaire en accordéon plein écran ; la maquette superpose deux plans :
///
/// * **en haut**, un aperçu vivant du CV, avec la section en cours d'édition
///   encadrée de rouge et marquée « EN COURS » ;
/// * **en bas**, une feuille glissante listant six sections numérotées, avec
///   leur statut — c'est elle qui pilote l'édition.
///
/// L'utilisateur voit donc en permanence l'effet de sa saisie sur le document,
/// ce que l'accordéon rendait impossible.
class EditorScreen extends StatefulWidget {
  const EditorScreen({
    super.key,
    this.cvId,
    required this.onBack,
    required this.onExport,
  });

  final String? cvId;
  final VoidCallback onBack;
  final VoidCallback onExport;

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  /// Section dépliée. `null` = feuille repliée sur la seule liste.
  CvSection? _open = CvSection.experience;

  /// Proposition de l'IA en cours d'affichage, le cas échéant.
  String? _proposal;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final library = context.watch<CvLibrary>();
    final doc = library.current;
    final data = model.cvData;

    return Scaffold(
      backgroundColor: Paper.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _TopBar(
              title: (doc?.title ?? 'CV').toUpperCase(),
              version: doc?.version ?? 1,
              onBack: widget.onBack,
              onPreview: widget.onExport,
            ),

            // ── Aperçu vivant ─────────────────────────────────
            Expanded(
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: OverflowBox(
                    alignment: Alignment.topCenter,
                    maxHeight: 900,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Space.xxxl,
                      ),
                      child: CvSheet(data: data, highlighted: _open),
                    ),
                  ),
                ),
              ),
            ),

            // ── Feuille de sections ───────────────────────────
            _SectionsSheet(
              data: data,
              open: _open,
              proposal: _proposal,
              onToggle: (s) => setState(() {
                _open = _open == s ? null : s;
                _proposal = null;
              }),
              onPropose: () => setState(() {
                _proposal = 'Piloté une équipe de 6 designers et porté le taux '
                    'de conversion de 18 % à 32 % en trois trimestres.';
              }),
              onApply: () {
                final first = model.cvData.experiences.firstOrNull;
                if (first != null && _proposal != null) {
                  model.updateExperience(
                    first.copyWith(description: _proposal),
                  );
                }
                setState(() => _proposal = null);
              },
              onDismiss: () => setState(() => _proposal = null),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Barre de titre ───────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.version,
    required this.onBack,
    required this.onPreview,
  });

  final String title;
  final int version;
  final VoidCallback onBack;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 24, color: Pen.primary),
          ),
          Expanded(
            child: Text(
              '$title · V$version',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Mono.overline.copyWith(letterSpacing: 2),
            ),
          ),
          TextButton(
            onPressed: onPreview,
            child: Text(
              'Aperçu',
              style: Sans.button.copyWith(color: Accent.red, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feuille de sections ──────────────────────────────────────────────────

class _SectionsSheet extends StatelessWidget {
  const _SectionsSheet({
    required this.data,
    required this.open,
    required this.proposal,
    required this.onToggle,
    required this.onPropose,
    required this.onApply,
    required this.onDismiss,
  });

  final CvData data;
  final CvSection? open;
  final String? proposal;
  final ValueChanged<CvSection> onToggle;
  final VoidCallback onPropose;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final done = CvSection.completedCount(data);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.58,
      ),
      decoration: const BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
        boxShadow: [
          BoxShadow(
              color: Color(0x141A1714), blurRadius: 24, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Space.md),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Paper.ruleStrong,
              borderRadius: BorderRadius.circular(Radii.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.lg,
              Space.xl,
              Space.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Sections', style: Serif.title.copyWith(fontSize: 26)),
                const Spacer(),
                Text(
                  '$done SUR ${CvSection.values.length} COMPLÈTES',
                  style: Mono.overline,
                ),
              ],
            ),
          ),
          const Divider(color: Paper.rule, height: 1),
          Flexible(
            child: ListView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + Space.xl,
              ),
              children: [
                for (final s in CvSection.values) ...[
                  _SectionRow(
                    section: s,
                    data: data,
                    isOpen: open == s,
                    proposal: open == s ? proposal : null,
                    onTap: () => onToggle(s),
                    onPropose: onPropose,
                    onApply: onApply,
                    onDismiss: onDismiss,
                  ),
                  const Divider(color: Paper.rule, height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.section,
    required this.data,
    required this.isOpen,
    required this.proposal,
    required this.onTap,
    required this.onPropose,
    required this.onApply,
    required this.onDismiss,
  });

  final CvSection section;
  final CvData data;
  final bool isOpen;
  final String? proposal;
  final VoidCallback onTap;
  final VoidCallback onPropose;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final complete = section.isComplete(data);
    final count = section.countLabel(data);

    return AnimatedContainer(
      duration: Motion.fast,
      color: isOpen ? Accent.redWash : Paper.sheet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.xl,
                vertical: Space.lg,
              ),
              child: Row(
                children: [
                  Text(section.number, style: Mono.index),
                  const SizedBox(width: Space.lg),
                  Expanded(
                    child: Text(
                      section.label,
                      style: Sans.itemTitle.copyWith(
                        color: isOpen
                            ? Accent.red
                            : (complete ? Pen.primary : Pen.secondary),
                      ),
                    ),
                  ),
                  if (isOpen && count != null)
                    Text(count, style: Mono.overlineAccent)
                  else if (complete)
                    const _StatusBadge(
                      'COMPLET',
                      fg: Status.okFg,
                      bg: Status.okBg,
                    )
                  else
                    const _StatusBadge(
                      'À COMPLÉTER',
                      fg: Status.warnFg,
                      bg: Status.warnBg,
                    ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                0,
                Space.xl,
                Space.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (proposal != null) ...[
                    _AiProposal(
                      text: proposal!,
                      onApply: onApply,
                      onOther: onDismiss,
                    ),
                    const SizedBox(height: Space.lg),
                  ],
                  SectionEditor(section: section, onPropose: onPropose),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.label, {required this.fg, required this.bg});

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

/// Encart de proposition — le seul endroit où l'IA agit vraiment sur le
/// document. Le portage se contentait d'un bouton qui jouait une animation
/// sans rien produire.
class _AiProposal extends StatelessWidget {
  const _AiProposal({
    required this.text,
    required this.onApply,
    required this.onOther,
  });

  final String text;
  final VoidCallback onApply;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: Accent.redLine),
      ),
      padding: const EdgeInsets.all(Space.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Accent.red,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '✦',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
              const SizedBox(width: Space.md),
              const Text("PROPOSITION DE L'IA", style: Mono.overlineAccent),
            ],
          ),
          const SizedBox(height: Space.md),
          Text(text, style: Sans.body.copyWith(color: Pen.primary)),
          const SizedBox(height: Space.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onApply,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: Accent.redWash,
                    foregroundColor: Accent.red,
                    side: const BorderSide(color: Accent.redLine),
                  ),
                  child: const Text('Appliquer'),
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onOther,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('Autre version'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
