import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/anim.dart';
import '../widgets/score_ring.dart';

/// Port de `ui/screens/DashboardScreen.kt`.
const Color _dBg = Color(0xFFF1ECFB);
const Color _dInk = Color(0xFF1C1626);
const Color _dCard = Color(0xFFFFFFFF);
const Color _dAccent = AppColors.accent;
const Color _dDark = Color(0xFF0D0920);
const Color _dDarkMid = Color(0xFF180C30);
const Color _dWhite = Color(0xFFEFEBFF);

class CvItem {
  const CvItem({
    required this.id,
    required this.title,
    required this.role,
    required this.edited,
    required this.score,
    this.isDraft = false,
  });

  final int id;
  final String title;
  final String role;
  final String edited;
  final int score;
  final bool isDraft;
}

const List<CvItem> sampleCvs = [
  CvItem(
    id: 1,
    title: 'CV Senior Dev',
    role: 'Développeur Full-Stack',
    edited: 'Il y a 2h',
    score: 92,
  ),
  CvItem(
    id: 2,
    title: 'CV UX/Produit',
    role: 'Product Designer',
    edited: 'Hier',
    score: 78,
    isDraft: true,
  ),
  CvItem(
    id: 3,
    title: 'CV Tech Lead',
    role: 'Engineering Manager',
    edited: 'Il y a 3j',
    score: 85,
  ),
];

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenEditor,
    required this.onCreateNew,
    required this.onProfile,
  });

  final ValueChanged<int> onOpenEditor;
  final VoidCallback onCreateNew;
  final VoidCallback onProfile;

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

  List<CvItem> get _filtered => switch (_activeFilter) {
        'Finalisés' => sampleCvs.where((c) => !c.isDraft).toList(),
        'Brouillons' => sampleCvs.where((c) => c.isDraft).toList(),
        _ => sampleCvs,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dBg,
      body: StaggerBuilder(
        count: 3,
        startDelay: const Duration(milliseconds: 80),
        stepDelay: const Duration(milliseconds: 100),
        builder: (context, vis) {
          return Stack(
            children: [
              Column(
                children: [
                  // ── En-tête sombre ─────────────────────────
                  EntranceItem(
                    visible: vis[0],
                    fromY: -28,
                    child: _DarkHeader(
                      statsVisible: _statsVisible,
                      onProfile: widget.onProfile,
                    ),
                  ),

                  // ── Puces de filtre ────────────────────────
                  EntranceItem(
                    visible: vis[1],
                    fromY: 14,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          for (final f in _filters) ...[
                            _FilterChip(
                              label: f,
                              active: f == _activeFilter,
                              onTap: () => setState(() => _activeFilter = f),
                            ),
                            const SizedBox(width: 9),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // ── Liste des CV ───────────────────────────
                  Expanded(
                    child: EntranceItem(
                      visible: vis[2],
                      fromY: 20,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filtered.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == _filtered.length) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 100,
                              ),
                              child: _CreateNewCard(
                                onTap: widget.onCreateNew,
                              ),
                            );
                          }
                          final cv = _filtered[index];
                          return _StaggeredCvCard(
                            index: index,
                            cv: cv,
                            onTap: () => widget.onOpenEditor(cv.id),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

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

// ── En-tête sombre avec statistiques ─────────────────────────────────────────

class _DarkHeader extends StatelessWidget {
  const _DarkHeader({required this.statsVisible, required this.onProfile});

  final bool statsVisible;
  final VoidCallback onProfile;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

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
                    const Text(
                      'Amina Diallo',
                      style: TextStyle(
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
                    child: const Text(
                      'AD',
                      style: TextStyle(
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
                    value: statsVisible ? 3 : 0,
                    label: 'CV actifs',
                    duration: const Duration(milliseconds: 700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DarkStatChip(
                    value: statsVisible ? 92 : 0,
                    label: 'Meilleur score',
                    highlight: true,
                    duration: const Duration(milliseconds: 1200),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DarkStatChip(
                    value: statsVisible ? 1 : 0,
                    label: 'Brouillon',
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
              color: active
                  ? Colors.transparent
                  : _dInk.withValues(alpha: 0.10),
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
  });

  final int index;
  final CvItem cv;
  final VoidCallback onTap;

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
      child: _CvCard(cv: widget.cv, onTap: widget.onTap),
    );
  }
}

class _CvCard extends StatelessWidget {
  const _CvCard({required this.cv, required this.onTap});

  final CvItem cv;
  final VoidCallback onTap;

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
                    cv.edited,
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
          ],
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
