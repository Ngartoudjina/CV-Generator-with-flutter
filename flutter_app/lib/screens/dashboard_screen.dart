import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cv_document.dart';
import '../state/cv_library.dart';
import '../theme/colors.dart';
import '../utils/anim.dart';
import '../widgets/score_ring.dart';
import 'profile_screen.dart';

/// Port de `ui/screens/DashboardScreen.kt`.
const Color _dBg = Color(0xFFF1ECFB);
const Color _dInk = Color(0xFF1C1626);
const Color _dCard = Color(0xFFFFFFFF);
const Color _dAccent = AppColors.accent;
const Color _dDark = Color(0xFF0D0920);
const Color _dDarkMid = Color(0xFF180C30);
const Color _dWhite = Color(0xFFEFEBFF);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenEditor,
    required this.onCreateNew,
    required this.onSignOut,
    required this.onReplayOnboarding,
  });

  /// Reçoit l'identifiant du document — la version Kotlin passait un `Int`
  /// d'une liste figée.
  final ValueChanged<String> onOpenEditor;
  final VoidCallback onCreateNew;
  final VoidCallback onSignOut;
  final VoidCallback onReplayOnboarding;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _filters = ['Tous', 'Finalisés', 'Brouillons'];

  String _activeFilter = 'Tous';
  int _activeTab = 0;
  bool _statsVisible = false;
  Timer? _statsTimer;

  @override
  void initState() {
    super.initState();
    _statsTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _statsVisible = true);
    });
  }

  @override
  void dispose() {
    _statsTimer?.cancel();
    super.dispose();
  }

  List<CvDocument> _filtered(List<CvDocument> all) => switch (_activeFilter) {
        'Finalisés' => all.where((c) => !c.isDraft).toList(),
        'Brouillons' => all.where((c) => c.isDraft).toList(),
        _ => all,
      };

  @override
  Widget build(BuildContext context) {
    final library = context.watch<CvLibrary>();
    final documents = library.sortedByDate;
    final filtered = _filtered(documents);

    return Scaffold(
      backgroundColor: _dBg,
      body: StaggerBuilder(
        count: 3,
        startDelay: const Duration(milliseconds: 80),
        stepDelay: const Duration(milliseconds: 100),
        builder: (context, vis) {
          return Stack(
            children: [
              // Le contenu change selon l'onglet actif. La version Kotlin
              // animait la sélection mais affichait toujours la même chose.
              switch (_activeTab) {
                1 => const ComingSoonTab(
                    icon: '⊟',
                    title: 'Modèles',
                    description:
                        "La galerie de modèles n'est pas encore implémentée. "
                        "L'export PDF utilise pour l'instant une mise en page "
                        'unique, définie dans PdfGenerator.',
                  ),
                2 => const ComingSoonTab(
                    icon: '✦',
                    title: 'Assistant IA',
                    description:
                        "La reformulation par IA n'est pas branchée : le "
                        "bouton de l'éditeur joue l'animation sans appeler de "
                        'service. Le score affiché est une mesure de '
                        'complétude, pas une analyse ATS.',
                  ),
                3 => ProfileScreen(
                    onSignOut: widget.onSignOut,
                    onReplayOnboarding: widget.onReplayOnboarding,
                  ),
                _ => _HomeTab(
                    vis: vis,
                    statsVisible: _statsVisible,
                    documents: documents,
                    filtered: filtered,
                    filters: _filters,
                    activeFilter: _activeFilter,
                    onFilterChange: (f) => setState(() => _activeFilter = f),
                    onOpenEditor: widget.onOpenEditor,
                    onCreateNew: widget.onCreateNew,
                    onProfile: () => setState(() => _activeTab = 3),
                  ),
              },

              // ── Barre d'onglets en verre ─────────────────
              Align(
                alignment: Alignment.bottomCenter,
                child: _BottomTabBar(
                  activeTab: _activeTab,
                  onTabChange: (i) => setState(() => _activeTab = i),
                  onCreateNew: widget.onCreateNew,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Onglet Accueil : en-tête, filtres, liste ─────────────────────────────────

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.vis,
    required this.statsVisible,
    required this.documents,
    required this.filtered,
    required this.filters,
    required this.activeFilter,
    required this.onFilterChange,
    required this.onOpenEditor,
    required this.onCreateNew,
    required this.onProfile,
  });

  final List<bool> vis;
  final bool statsVisible;
  final List<CvDocument> documents;
  final List<CvDocument> filtered;
  final List<String> filters;
  final String activeFilter;
  final ValueChanged<String> onFilterChange;
  final ValueChanged<String> onOpenEditor;
  final VoidCallback onCreateNew;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EntranceItem(
          visible: vis[0],
          fromY: -28,
          child: _DarkHeader(
            statsVisible: statsVisible,
            documents: documents,
            onProfile: onProfile,
          ),
        ),
        EntranceItem(
          visible: vis[1],
          fromY: 14,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                for (final f in filters) ...[
                  _FilterChip(
                    label: f,
                    active: f == activeFilter,
                    onTap: () => onFilterChange(f),
                  ),
                  const SizedBox(width: 9),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: EntranceItem(
            visible: vis[2],
            fromY: 20,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filtered.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == filtered.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 100),
                    child: Column(
                      children: [
                        if (filtered.isEmpty) _EmptyState(filter: activeFilter),
                        _CreateNewCard(onTap: onCreateNew),
                      ],
                    ),
                  );
                }
                final cv = filtered[index];
                return _StaggeredCvCard(
                  index: index,
                  cv: cv,
                  onTap: () => onOpenEditor(cv.id),
                  onDelete: () => context.read<CvLibrary>().remove(cv.id),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── En-tête sombre avec statistiques ─────────────────────────────────────────

class _DarkHeader extends StatelessWidget {
  const _DarkHeader({
    required this.statsVisible,
    required this.documents,
    required this.onProfile,
  });

  final bool statsVisible;
  final List<CvDocument> documents;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    // Statistiques calculées, là où la version Kotlin animait 3 / 92 / 1 en dur.
    final bestScore = documents.isEmpty
        ? 0
        : documents.map((d) => d.score).reduce((a, b) => a > b ? a : b);
    final drafts = documents.where((d) => d.isDraft).length;

    // Le nom affiché suit le CV le plus récent plutôt qu'un « Amina Diallo »
    // codé en dur.
    final owner = documents
        .map((d) => d.data.personalInfo.fullName.trim())
        .firstWhere((n) => n.isNotEmpty, orElse: () => 'Bienvenue');
    final initials = owner
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_dDark, _dDarkMid, Color(0x000D0920)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: topPad + 16,
          bottom: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/logo_icon.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bonjour 👋',
                      style: TextStyle(
                        fontSize: 13,
                        color: _dWhite.withValues(alpha: 0.55),
                      ),
                    ),
                    Text(
                      owner,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _dWhite,
                      ),
                    ),
                  ],
                ),
                PressScale(
                  pressedScale: 0.92,
                  onTap: onProfile,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentCoGradient,
                      border: Border.all(
                        color: _dWhite.withValues(alpha: 0.20),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DarkStatChip(
                    value: statsVisible ? documents.length : 0,
                    label: 'CV actifs',
                    duration: const Duration(milliseconds: 700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DarkStatChip(
                    value: statsVisible ? bestScore : 0,
                    label: 'Meilleur score',
                    highlight: true,
                    duration: const Duration(milliseconds: 1200),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DarkStatChip(
                    value: statsVisible ? drafts : 0,
                    label: drafts > 1 ? 'Brouillons' : 'Brouillon',
                    duration: const Duration(milliseconds: 500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkStatChip extends StatelessWidget {
  const _DarkStatChip({
    required this.value,
    required this.label,
    required this.duration,
    this.highlight = false,
  });

  final int value;
  final String label;
  final Duration duration;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: highlight
            ? AppColors.accentGradient
            : LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? Colors.transparent
              : Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        children: [
          AnimatedIntBuilder(
            value: value,
            duration: duration,
            builder: (context, current) => Text(
              '$current',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.65),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Puce de filtre ───────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: active ? 1.04 : 1,
        duration: const Duration(milliseconds: 260),
        curve: kBouncy,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(
                    colors: [
                      _dAccent,
                      AppColors.accentCo.withValues(alpha: 0.8),
                    ],
                  )
                : const LinearGradient(colors: [_dCard, _dCard]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  active ? Colors.transparent : _dInk.withValues(alpha: 0.10),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? Colors.white : _dInk.withValues(alpha: 0.60),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Carte CV avec entrée décalée ─────────────────────────────────────────────

class _StaggeredCvCard extends StatefulWidget {
  const _StaggeredCvCard({
    required this.index,
    required this.cv,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final CvDocument cv;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  State<_StaggeredCvCard> createState() => _StaggeredCvCardState();
}

class _StaggeredCvCardState extends State<_StaggeredCvCard> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(Duration(milliseconds: 200 + widget.index * 100), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EntranceItem(
      visible: _visible,
      fromY: 32,
      fromScale: 0.94,
      child: _CvCard(
        cv: widget.cv,
        onTap: widget.onTap,
        onDelete: widget.onDelete,
      ),
    );
  }
}

class _CvCard extends StatelessWidget {
  const _CvCard({
    required this.cv,
    required this.onTap,
    required this.onDelete,
  });

  final CvDocument cv;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      pressedScale: 0.975,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _dCard,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _dInk.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const _CvThumbnail(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          cv.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _dInk,
                          ),
                        ),
                      ),
                      if (cv.isDraft) ...[
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _dAccent.withValues(alpha: 0.12),
                                AppColors.accentCo.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _dAccent.withValues(alpha: 0.28),
                            ),
                          ),
                          child: const Text(
                            'Brouillon',
                            style: TextStyle(
                              fontSize: 9,
                              color: _dAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    cv.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: _dInk.withValues(alpha: 0.52),
                    ),
                  ),
                  Text(
                    cv.editedLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: _dInk.withValues(alpha: 0.32),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ScoreRingSmall(score: cv.score),
            _DeleteButton(title: cv.title, onConfirm: onDelete),
          ],
        ),
      ),
    );
  }
}

/// Suppression avec confirmation — un CV effacé par erreur n'est pas
/// récupérable, la bibliothèque ne gardant pas d'historique.
class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.title, required this.onConfirm});

  final String title;
  final VoidCallback onConfirm;

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer ce CV ?'),
        content: Text('« $title » sera définitivement effacé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok ?? false) onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _confirm(context),
      tooltip: 'Supprimer',
      iconSize: 18,
      visualDensity: VisualDensity.compact,
      icon: Icon(
        Icons.delete_outline,
        color: _dInk.withValues(alpha: 0.30),
      ),
    );
  }
}

/// Affiché quand un filtre ne renvoie aucun CV.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});

  final String filter;

  @override
  Widget build(BuildContext context) {
    final message = switch (filter) {
      'Finalisés' => 'Aucun CV finalisé pour l\'instant.',
      'Brouillons' => 'Aucun brouillon — tout est finalisé.',
      _ => 'Aucun CV. Créez le premier ci-dessous.',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: _dInk.withValues(alpha: 0.42),
        ),
      ),
    );
  }
}

class _CvThumbnail extends StatelessWidget {
  const _CvThumbnail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 70,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: _dBg,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: _dInk.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FractionallySizedBox(
            widthFactor: 0.7,
            alignment: Alignment.centerLeft,
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                gradient: AppColors.accentCoGradient,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Divider(height: 0.5, color: _dInk.withValues(alpha: 0.10)),
          const SizedBox(height: 5),
          for (final w in [0.9, 0.7, 0.8, 0.6, 0.75]) ...[
            FractionallySizedBox(
              widthFactor: w,
              alignment: Alignment.centerLeft,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  color: _dInk.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 2.5),
          ],
        ],
      ),
    );
  }
}

// ── Carte « créer un nouveau CV » ────────────────────────────────────────────

class _CreateNewCard extends StatelessWidget {
  const _CreateNewCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      pressedScale: 0.97,
      onTap: onTap,
      child: GradientBorder(
        radius: 18,
        width: 2,
        gradient: LinearGradient(
          colors: [
            _dAccent.withValues(alpha: 0.45),
            AppColors.accentCo.withValues(alpha: 0.30),
          ],
        ),
        fillGradient: LinearGradient(
          colors: [
            _dAccent.withValues(alpha: 0.06),
            AppColors.accentCo.withValues(alpha: 0.04),
          ],
        ),
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.accentCoGradient,
                ),
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Créer un nouveau CV',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _dAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Barre d'onglets inférieure ───────────────────────────────────────────────

class _BottomTabBar extends StatelessWidget {
  const _BottomTabBar({
    required this.activeTab,
    required this.onTabChange,
    required this.onCreateNew,
  });

  final int activeTab;
  final ValueChanged<int> onTabChange;
  final VoidCallback onCreateNew;

  static const _tabs = [
    ('⌂', 'Accueil'),
    ('⊟', 'Modèles'),
    null,
    ('✦', 'IA'),
    ('◯', 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _dCard.withValues(alpha: 0.97),
        boxShadow: [
          BoxShadow(
            color: _dInk.withValues(alpha: 0.14),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _dAccent.withValues(alpha: 0.28),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Expanded(
                      child: _tabs[i] == null
                          ? _CenterFab(onTap: onCreateNew)
                          : _TabItem(
                              icon: _tabs[i]!.$1,
                              label: _tabs[i]!.$2,
                              active: (i > 2 ? i - 1 : i) == activeTab,
                              onTap: () => onTabChange(i > 2 ? i - 1 : i),
                            ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _CenterFab extends StatelessWidget {
  const _CenterFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PulseBuilder(
          min: 0,
          max: 0.32,
          duration: const Duration(milliseconds: 1400),
          builder: (context, alpha) => Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _dAccent.withValues(alpha: alpha),
            ),
          ),
        ),
        PressScale(
          pressedScale: 0.88,
          onTap: onTap,
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.accentCoGradient,
            ),
            child: const Text(
              '+',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? _dAccent : _dInk.withValues(alpha: 0.35);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: active ? 1.18 : 1,
            duration: const Duration(milliseconds: 320),
            curve: kBouncy,
            child: Text(
              icon,
              style: TextStyle(fontSize: active ? 20 : 18, color: color),
            ),
          ),
          AnimatedOpacity(
            opacity: active ? 1 : 0.38,
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedScale(
            scale: active ? 1 : 0,
            duration: const Duration(milliseconds: 240),
            curve: kBouncy,
            child: Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                gradient: AppColors.accentCoGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
