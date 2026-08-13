import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/anim.dart';

/// Port de `ui/screens/WelcomeScreen.kt`.
const Color _wBg = Color(0xFF0D0920);
const Color _wBgMid = Color(0xFF180C30);
const Color _wInk = Color(0xFFEFEBFF);
const Color _wInkSub = Color(0xFFBBB0D8);
const Color _wAccent = AppColors.accent;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  static const _words = ['remarquer', 'recruter', 'choisir', 'embaucher'];

  int _wordIndex = 0;
  int _targetScore = 0;
  Timer? _scoreTimer;
  Timer? _wordTimer;

  late final AnimationController _blobs = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9000),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _scoreTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _targetScore = 94);
    });
    _wordTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (mounted) {
        setState(() => _wordIndex = (_wordIndex + 1) % _words.length);
      }
    });
  }

  @override
  void dispose() {
    _scoreTimer?.cancel();
    _wordTimer?.cancel();
    _blobs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_wBg, _wBgMid, _wBg],
          ),
        ),
        child: Stack(
          children: [
            // ── Blobs de dégradé animés ────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _blobs,
                builder: (context, _) => CustomPaint(
                  painter: _BlobPainter(progress: _blobs.value),
                ),
              ),
            ),

            SafeArea(
              child: StaggerBuilder(
                count: 8,
                startDelay: const Duration(milliseconds: 100),
                stepDelay: const Duration(milliseconds: 85),
                builder: (context, vis) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Barre supérieure ───────────────────
                        EntranceItem(
                          visible: vis[0],
                          fromY: -22,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'assets/images/logo_icon.png',
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.contain,
                                ),
                                _LoginPill(onTap: widget.onLogin),
                              ],
                            ),
                          ),
                        ),

                        // ── Bloc titre ─────────────────────────
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            EntranceItem(
                              visible: vis[1],
                              fromY: 18,
                              fromScale: 0.90,
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: _GradientBadge(
                                  '✦  GÉNÉRATEUR DE CV · IA',
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            EntranceItem(
                              visible: vis[2],
                              fromY: 28,
                              child: const Text('Le CV qui', style: _heroStyle),
                            ),
                            EntranceItem(
                              visible: vis[3],
                              fromY: 28,
                              child: const Text('vous fait', style: _heroStyle),
                            ),
                            EntranceItem(
                              visible: vis[4],
                              fromY: 28,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 240),
                                reverseDuration:
                                    const Duration(milliseconds: 160),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(begin: 0.78, end: 1)
                                          .animate(animation),
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.33),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: GradientText(
                                  '${_words[_wordIndex]}.',
                                  key: ValueKey(_wordIndex),
                                  gradient: const LinearGradient(
                                    colors: [_wAccent, AppColors.accentCo],
                                  ),
                                  style: _heroStyle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            EntranceItem(
                              visible: vis[5],
                              fromY: 16,
                              child: const Text(
                                "Décrivez votre parcours. L'IA le transforme en CV "
                                'qui décroche des entretiens.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _wInkSub,
                                  height: 1.56,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ── Carte flottante ────────────────────
                        EntranceItem(
                          visible: vis[6],
                          fromY: 38,
                          fromScale: 0.86,
                          child: FloatingBox(
                            amplitude: 6,
                            period: const Duration(milliseconds: 3000),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PulseBuilder(
                                  min: 0.10,
                                  max: 0.30,
                                  duration: const Duration(milliseconds: 1800),
                                  builder: (context, glow) => Container(
                                    width: 300,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        colors: [
                                          _wAccent.withValues(alpha: glow),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                _HeroCard(targetScore: _targetScore),
                              ],
                            ),
                          ),
                        ),

                        // ── Preuve sociale ─────────────────────
                        EntranceItem(
                          visible: vis[6],
                          fromY: 14,
                          child: const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                _OverlappingAvatars(),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '★★★★★',
                                      style: TextStyle(
                                        color: _wAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Rejoint par 12 000+ candidats',
                                      style: TextStyle(
                                        color: _wInkSub,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Boutons d'appel à l'action ─────────
                        EntranceItem(
                          visible: vis[7],
                          fromY: 30,
                          fromScale: 0.94,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 36),
                            child: Column(
                              children: [
                                PressScale(
                                  pressedScale: 0.965,
                                  onTap: widget.onGetStarted,
                                  child: Container(
                                    height: 58,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.accentGradient,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Text(
                                      'Créer mon CV — gratuit  →',
                                      style: TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                PressScale(
                                  pressedScale: 0.97,
                                  onTap: widget.onLogin,
                                  child: Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: _wInk.withValues(alpha: 0.22),
                                      ),
                                    ),
                                    child: Text(
                                      'Voir un exemple en 30 s',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: _wInk.withValues(alpha: 0.72),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _heroStyle = TextStyle(
  fontSize: 43,
  fontWeight: FontWeight.w800,
  color: _wInk,
  letterSpacing: -1.5,
  height: 1.16,
);

// ── Blobs animés ─────────────────────────────────────────────────────────────

class _BlobPainter extends CustomPainter {
  _BlobPainter({required this.progress});

  final double progress;

  void _blob(Canvas canvas, Offset center, double radius, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(rect),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress;
    _blob(
      canvas,
      Offset(size.width * 0.55 + 55 * p, -80 + 35 * p),
      size.width * 0.82,
      _wAccent.withValues(alpha: 0.42),
    );
    _blob(
      canvas,
      Offset(size.width * 0.90 - 70 * p, size.height * 0.52 + 55 * p),
      size.width * 0.62,
      AppColors.accentCo.withValues(alpha: 0.24),
    );
    _blob(
      canvas,
      Offset(size.width * 0.12 + 40 * p, size.height * 0.78 - 30 * p),
      size.width * 0.50,
      AppColors.amethysteAccent.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.progress != progress;
}

// ── Atomes d'interface ───────────────────────────────────────────────────────

class _GradientBadge extends StatelessWidget {
  const _GradientBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _wAccent.withValues(alpha: 0.28),
            AppColors.accentCo.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _wAccent.withValues(alpha: 0.42)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.accentCo,
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LoginPill extends StatelessWidget {
  const _LoginPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      pressedScale: 0.94,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _wInk.withValues(alpha: 0.24)),
        ),
        child: Text(
          'Connexion',
          style: TextStyle(
            color: _wInk.withValues(alpha: 0.82),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Carte héro — glassmorphism sur fond sombre ───────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.targetScore});

  final int targetScore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 296,
      child: GradientBorder(
        radius: 28,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.28),
            Colors.white.withValues(alpha: 0.06),
            _wAccent.withValues(alpha: 0.22),
          ],
        ),
        fill: Colors.white.withValues(alpha: 0.07),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: AnimatedIntBuilder(
            value: targetScore,
            duration: const Duration(milliseconds: 1600),
            builder: (context, score) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _MiniCvThumbnail(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Score ATS',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _wInk,
                              ),
                            ),
                            Text(
                              "Optimisé à l'instant",
                              style: TextStyle(
                                fontSize: 11,
                                color: _wInkSub.withValues(alpha: 0.65),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                height: 6,
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ColoredBox(
                                        color: _wInk.withValues(alpha: 0.10),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      widthFactor: score / 100,
                                      child: const DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: AppColors.accentCoGradient,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GradientText(
                        '$score',
                        gradient: AppColors.accentCoGradient,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _AiChip(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MiniCvThumbnail extends StatelessWidget {
  const _MiniCvThumbnail();

  @override
  Widget build(BuildContext context) {
    const lines = [(0.85, true), (0.62, false), (0.74, false)];
    return Container(
      width: 52,
      height: 68,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amina D.',
            style: TextStyle(
              fontSize: 7,
              height: 1.14,
              fontWeight: FontWeight.w600,
              color: _wInk,
            ),
          ),
          const SizedBox(height: 4),
          Divider(height: 0.5, color: _wInk.withValues(alpha: 0.15)),
          const SizedBox(height: 4),
          for (final (w, bold) in lines) ...[
            FractionallySizedBox(
              widthFactor: w,
              alignment: Alignment.centerLeft,
              child: Container(
                height: 2.5,
                decoration: BoxDecoration(
                  color: bold
                      ? _wAccent.withValues(alpha: 0.90)
                      : _wInk.withValues(alpha: 0.16),
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

class _AiChip extends StatelessWidget {
  const _AiChip();

  @override
  Widget build(BuildContext context) {
    return GradientBorder(
      radius: 14,
      gradient: LinearGradient(
        colors: [
          _wAccent.withValues(alpha: 0.52),
          AppColors.accentCo.withValues(alpha: 0.28),
        ],
      ),
      fillGradient: LinearGradient(
        colors: [
          _wAccent.withValues(alpha: 0.18),
          AppColors.accentCo.withValues(alpha: 0.10),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.accentCoGradient,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '✦',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                "Piloté une équipe de 6 et accru le CA de 32 %.",
                style: TextStyle(
                  fontSize: 11.5,
                  color: _wInk.withValues(alpha: 0.85),
                  height: 1.39,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatars superposés ───────────────────────────────────────────────────────

class _OverlappingAvatars extends StatelessWidget {
  const _OverlappingAvatars();

  @override
  Widget build(BuildContext context) {
    const colors = [
      AppColors.accent,
      AppColors.accentCo,
      AppColors.amethysteAccent,
      AppColors.indigoAccent,
    ];
    const initials = ['A', 'M', 'K', 'S'];

    return SizedBox(
      width: 82,
      height: 28,
      child: Stack(
        children: [
          for (var i = 0; i < colors.length; i++)
            Positioned(
              left: i * 18,
              child: Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _wBg, width: 2),
                  gradient: LinearGradient(
                    colors: [
                      colors[i],
                      colors[i].withValues(alpha: 0.55),
                    ],
                  ),
                ),
                child: Text(
                  initials[i],
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
