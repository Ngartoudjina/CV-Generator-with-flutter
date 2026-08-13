import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../utils/anim.dart';
import '../../widgets/score_ring.dart';

/// Port de `ui/onboarding/OnboardingScreen.kt`.
const Color _obAccent = Color(0xFF6C40E0);
const Color _obAccentCo = Color(0xFFC49AEC);
const Color _obBg = Color(0xFFF1ECFB);
const Color _obCard = Color(0xFFFFFFFF);
const Color _obInk = Color(0xFF1C1626);
const Color _obPaper = Color(0xFFFFFFFF);
const Color _obInkPaper = Color(0xFF241B30);
const Color _obDark = Color(0xFF0D0920);
const Color _obDarkMid = Color(0xFF180C30);
const Color _obWhite = Color(0xFFEFEBFF);

// ── Flux principal ───────────────────────────────────────────────────────────

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;
  bool _forward = true;

  void _go(int next) {
    setState(() {
      _forward = next > _step;
      _step = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _obBg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, if (current != null) current],
        ),
        transitionBuilder: (child, animation) {
          final incoming = child.key == ValueKey(_step);
          final begin = incoming
              ? Offset(_forward ? 1 : -1, 0)
              : Offset(_forward ? -1 : 1, 0);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(begin: begin, end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_step),
          child: switch (_step) {
            0 => _SplashScreen(onNext: () => _go(1)),
            1 => _FeatureWriteScreen(
                onNext: () => _go(2),
                onSkip: () => _go(4),
              ),
            2 => _FeatureScoreScreen(
                onNext: () => _go(3),
                onSkip: () => _go(4),
              ),
            3 => _FeatureExportScreen(
                onNext: () => _go(4),
                onSkip: () => _go(4),
              ),
            4 => _PersonaScreen(onNext: () => _go(5)),
            _ => _SuccessScreen(
                onComplete: widget.onComplete,
                onRestart: () => _go(0),
              ),
          },
        ),
      ),
    );
  }
}

// ── Atomes partagés ──────────────────────────────────────────────────────────

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _obAccent,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    );
  }
}

class _ObTitle extends StatelessWidget {
  const _ObTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _obInk,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        height: 1.18,
      ),
    );
  }
}

class _ObSub extends StatelessWidget {
  const _ObSub(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: _obInk.withValues(alpha: 0.55),
        fontSize: 15,
        height: 1.47,
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({
    required this.text,
    required this.onTap,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return PressScale(
      pressedScale: 0.97,
      enabled: enabled,
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? _obAccent : _obAccent.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          '$text  →',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: _obBg,
          ),
        ),
      ),
    );
  }
}

class _GhostBtn extends StatelessWidget {
  const _GhostBtn({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: TextStyle(
          color: _obInk.withValues(alpha: 0.5),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: kBouncy,
              width: i == active ? 22 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active ? _obAccent : _obInk.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
      ],
    );
  }
}

class _ObHeader extends StatelessWidget {
  const _ObHeader({this.onSkip});

  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/logo_icon.png',
          width: 64,
          height: 64,
          fit: BoxFit.contain,
        ),
        if (onSkip != null)
          TextButton(
            onPressed: onSkip,
            child: Text(
              'Passer',
              style: TextStyle(
                color: _obInk.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
          )
        else
          const SizedBox(width: 30, height: 30),
      ],
    );
  }
}

class _ObFooter extends StatelessWidget {
  const _ObFooter({required this.dotsActive, required this.onNext});

  final int dotsActive;
  final VoidCallback onNext;

  /// Les trois écrans de présentation utilisent le même libellé ; le
  /// paramètre `label` de la version Kotlin n'était jamais surchargé.
  static const String label = 'Suivant';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProgressDots(count: 3, active: dotsActive),
        const SizedBox(height: 14),
        _PrimaryBtn(text: label, onTap: onNext),
      ],
    );
  }
}

// ── Écran 0 · Splash ─────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_obDark, _obDarkMid, _obDark],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo_icon.png',
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'IA · ERA',
                        style: TextStyle(
                          fontSize: 12,
                          color: _obAccentCo,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Votre parcours, sublimé par l'intelligence artificielle.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          color: _obWhite.withValues(alpha: 0.80),
                          height: 1.36,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PressScale(
                pressedScale: 0.97,
                onTap: onNext,
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Commencer  →',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: _obWhite.withValues(alpha: 0.22)),
                ),
                child: Text(
                  "J'ai déjà un compte",
                  style: TextStyle(
                    color: _obWhite.withValues(alpha: 0.65),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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

// ── Écran 1 · Rédaction IA ───────────────────────────────────────────────────

class _FeatureWriteScreen extends StatefulWidget {
  const _FeatureWriteScreen({required this.onNext, required this.onSkip});

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_FeatureWriteScreen> createState() => _FeatureWriteScreenState();
}

class _FeatureWriteScreenState extends State<_FeatureWriteScreen>
    with SingleTickerProviderStateMixin {
  static const _raw = 'jai géré une équipe et augmenté les ventes';

  String _typed = '';
  String _phase = 'typing';

  late final AnimationController _blink = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  Future<void> _startTyping() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    for (var i = 1; i <= _raw.length; i++) {
      if (!mounted) return;
      setState(() => _typed = _raw.substring(0, i));
      await Future<void>.delayed(const Duration(milliseconds: 42));
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _phase = 'think');
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _phase = 'done');
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = _phase == 'done';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ObHeader(onSkip: widget.onSkip),
            const SizedBox(height: 16),
            const _Eyebrow('01 · Rédaction IA'),
            const SizedBox(height: 16),
            const _ObTitle("Décrivez.\nL'IA rédige."),
            const SizedBox(height: 16),
            const _ObSub(
              "Écrivez comme vous parlez. L'IA transforme vos phrases en "
              'accomplissements percutants.',
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Bulle de saisie brute
                  Container(
                    decoration: BoxDecoration(
                      color: _obCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _obInk.withValues(alpha: 0.07)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vous écrivez',
                          style: TextStyle(
                            color: _obInk.withValues(alpha: 0.4),
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                _typed,
                                style: TextStyle(
                                  color: _obInk.withValues(alpha: 0.85),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (_phase == 'typing')
                              FadeTransition(
                                opacity: _blink,
                                child: Container(
                                  width: 2,
                                  height: 18,
                                  color: _obAccent,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Indicateur IA
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _obAccent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Text(
                            '✦',
                            style: TextStyle(color: _obAccent, fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          done ? "Reformulé par l'IA" : "L'IA reformule…",
                          style: TextStyle(
                            color: _obInk.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Sortie polie
                  AnimatedSlide(
                    offset: done ? Offset.zero : const Offset(0, 0.12),
                    duration: const Duration(milliseconds: 320),
                    child: AnimatedOpacity(
                      opacity: done ? 1 : 0.25,
                      duration: const Duration(milliseconds: 320),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _obAccent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _obAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Résultat pro',
                              style: TextStyle(
                                color: _obAccent,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text.rich(
                              TextSpan(
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _obInk,
                                  height: 1.47,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Piloté',
                                    style: TextStyle(
                                      color: _obAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' une équipe de 6 et '),
                                  TextSpan(
                                    text: "accru le chiffre d'affaires de 32 %",
                                    style: TextStyle(
                                      color: _obAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(text: ' en 9 mois.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ObFooter(dotsActive: 0, onNext: widget.onNext),
          ],
        ),
      ),
    );
  }
}

// ── Écran 2 · Score de crédibilité ───────────────────────────────────────────

class _FeatureScoreScreen extends StatefulWidget {
  const _FeatureScoreScreen({required this.onNext, required this.onSkip});

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_FeatureScoreScreen> createState() => _FeatureScoreScreenState();
}

class _FeatureScoreScreenState extends State<_FeatureScoreScreen> {
  static const _factors = [
    "Verbes d'action",
    'Résultats chiffrés',
    'Mots-clés ATS',
  ];

  int _targetScore = 0;
  int _lit = 0;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _timers.add(Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _targetScore = 92);
    }));
    _timers.add(Timer(const Duration(milliseconds: 1000), () {
      if (mounted) setState(() => _lit = 1);
    }));
    _timers.add(Timer(const Duration(milliseconds: 1300), () {
      if (mounted) setState(() => _lit = 2);
    }));
    _timers.add(Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _lit = 3);
    }));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ObHeader(onSkip: widget.onSkip),
            const SizedBox(height: 16),
            const _Eyebrow('02 · Score de crédibilité'),
            const SizedBox(height: 16),
            const _ObTitle('Mesurez votre impact,\nen direct.'),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: ScoreRingLarge(score: _targetScore)),
                  const SizedBox(height: 30),
                  for (final (idx, label) in _factors.indexed) ...[
                    _FactorRow(label: label, lit: _lit >= idx + 1),
                    if (idx < _factors.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            _ObFooter(dotsActive: 1, onNext: widget.onNext),
          ],
        ),
      ),
    );
  }
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.label, required this.lit});

  final String label;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: lit ? Offset.zero : const Offset(-0.015, 0),
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: lit ? 1 : 0.4,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _obCard,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: lit
                  ? _obAccent.withValues(alpha: 0.3)
                  : _obInk.withValues(alpha: 0.06),
            ),
          ),
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lit ? _obAccent : _obInk.withValues(alpha: 0.12),
                ),
                child: lit
                    ? const Text(
                        '✓',
                        style: TextStyle(
                          color: _obBg,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  color: _obInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Écran 3 · Export & ATS ───────────────────────────────────────────────────

class _FeatureExportScreen extends StatefulWidget {
  const _FeatureExportScreen({required this.onNext, required this.onSkip});

  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  State<_FeatureExportScreen> createState() => _FeatureExportScreenState();
}

class _FeatureExportScreenState extends State<_FeatureExportScreen> {
  bool _show = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const lines = [(0.85, true), (0.70, false), (0.78, false)];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ObHeader(onSkip: widget.onSkip),
            const SizedBox(height: 16),
            const _Eyebrow('03 · Export & ATS'),
            const SizedBox(height: 16),
            const _ObTitle('Un PDF impeccable,\nlu par les robots.'),
            const SizedBox(height: 16),
            const _ObSub(
              'Mise en page soignée à l\'écran, structure parfaitement '
              'lisible par les filtres ATS.',
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Maquette de CV
                  AnimatedSlide(
                    offset: _show ? Offset.zero : const Offset(0, 0.04),
                    duration: const Duration(milliseconds: 420),
                    curve: kBouncy,
                    child: Container(
                      width: 200,
                      decoration: BoxDecoration(
                        color: _obPaper,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: _obInk.withValues(alpha: 0.18),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amina Diallo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _obInkPaper,
                            ),
                          ),
                          const Text(
                            'Chef de projet · Marketing',
                            style: TextStyle(
                              fontSize: 9,
                              color: _obAccent,
                              letterSpacing: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              height: 1,
                              color: _obInkPaper.withValues(alpha: 0.15),
                            ),
                          ),
                          const Text(
                            'Expérience',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _obInkPaper,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final (i, (w, strong)) in lines.indexed) ...[
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: _show ? w : 0,
                              ),
                              duration: Duration(
                                milliseconds: 600 + i * 100,
                              ),
                              builder: (context, factor, _) =>
                                  FractionallySizedBox(
                                widthFactor: factor,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: _obInkPaper.withValues(
                                      alpha: strong ? 0.55 : 0.16,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          const SizedBox(height: 8),
                          const Text(
                            'Compétences',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _obInkPaper,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedOpacity(
                            opacity: _show ? 1 : 0,
                            duration: const Duration(milliseconds: 400),
                            child: Row(
                              children: [
                                for (final tag in ['Stratégie', 'SEO', 'Figma'])
                                  Padding(
                                    padding: const EdgeInsets.only(right: 5),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _obAccent.withValues(
                                          alpha: 0.18,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: _obInkPaper,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Badge ATS
                  Positioned(
                    top: 16,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: _show ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: _obAccent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text(
                          '✓ Compatible ATS',
                          style: TextStyle(
                            color: _obBg,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Badge PDF
                  Positioned(
                    bottom: 16,
                    left: 0,
                    child: AnimatedOpacity(
                      opacity: _show ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _obCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _obInk.withValues(alpha: 0.12),
                          ),
                        ),
                        child: const Text(
                          'PDF · A4 · 300dpi',
                          style: TextStyle(fontSize: 10, color: _obInk),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ObFooter(dotsActive: 2, onNext: widget.onNext),
          ],
        ),
      ),
    );
  }
}

// ── Écran 4 · Persona ────────────────────────────────────────────────────────

class _PersonaScreen extends StatefulWidget {
  const _PersonaScreen({required this.onNext});

  final VoidCallback onNext;

  @override
  State<_PersonaScreen> createState() => _PersonaScreenState();
}

class _PersonaScreenState extends State<_PersonaScreen> {
  static const _roles = [
    'Étudiant·e',
    'Cadre',
    'Entrepreneur·e',
    'En reconversion',
  ];
  static const _sectors = [
    'Tech',
    'Marketing',
    'Finance',
    'Santé',
    'Design',
    'Éducation',
  ];

  String? _role;
  String? _sector;

  bool get _ready => _role != null && _sector != null;

  /// Équivalent de `List.chunked(n)` en Kotlin.
  List<List<T>> _chunked<T>(List<T> list, int size) {
    return [
      for (var i = 0; i < list.length; i += size)
        list.sublist(i, (i + size).clamp(0, list.length)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const _Eyebrow('Pour commencer'),
            const SizedBox(height: 4),
            const _ObTitle('Parlez-nous de vous.'),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Vous êtes…',
                      style: TextStyle(
                        color: _obInk.withValues(alpha: 0.45),
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final row in _chunked(_roles, 2)) ...[
                      Row(
                        children: [
                          for (final (i, r) in row.indexed) ...[
                            Expanded(
                              child: _SelectChip(
                                label: r,
                                selected: _role == r,
                                onTap: () => setState(() => _role = r),
                              ),
                            ),
                            if (i < row.length - 1) const SizedBox(width: 9),
                          ],
                        ],
                      ),
                      const SizedBox(height: 9),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Votre secteur',
                      style: TextStyle(
                        color: _obInk.withValues(alpha: 0.45),
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final row in _chunked(_sectors, 3)) ...[
                      Row(
                        children: [
                          for (final (i, s) in row.indexed) ...[
                            Expanded(
                              child: _SelectChip(
                                label: s,
                                selected: _sector == s,
                                onTap: () => setState(() => _sector = s),
                              ),
                            ),
                            if (i < row.length - 1) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
            const _ProgressDots(count: 3, active: 2),
            const SizedBox(height: 12),
            AnimatedOpacity(
              opacity: _ready ? 1 : 0.45,
              duration: const Duration(milliseconds: 250),
              child: SizedBox(
                width: double.infinity,
                child: _PrimaryBtn(
                  text: 'Créer mon CV',
                  onTap: widget.onNext,
                  enabled: _ready,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.04 : 1,
        duration: const Duration(milliseconds: 280),
        curve: kBouncy,
        child: GradientBorder(
          radius: 13,
          gradient: selected
              ? LinearGradient(
                  colors: [
                    _obAccent.withValues(alpha: 0.85),
                    _obAccentCo.withValues(alpha: 0.55),
                  ],
                )
              : LinearGradient(
                  colors: [
                    _obInk.withValues(alpha: 0.14),
                    _obInk.withValues(alpha: 0.10),
                  ],
                ),
          fillGradient: selected
              ? LinearGradient(
                  colors: [
                    _obAccent.withValues(alpha: 0.22),
                    _obAccentCo.withValues(alpha: 0.14),
                  ],
                )
              : const LinearGradient(colors: [_obCard, _obCard]),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selected) ...[
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_obAccent, _obAccentCo],
                      ),
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? _obAccent : _obInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Écran 5 · Succès ─────────────────────────────────────────────────────────

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen({required this.onComplete, required this.onRestart});

  final VoidCallback onComplete;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logo_icon.png',
                width: 72,
                height: 72,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PulseBuilder(
                    min: 0.12,
                    max: 0.38,
                    duration: const Duration(milliseconds: 1300),
                    builder: (context, alpha) => Container(
                      width: 136,
                      height: 136,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            _obAccent.withValues(alpha: alpha),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.accentGradient,
                    ),
                    child: const Text(
                      '✓',
                      style: TextStyle(
                        fontSize: 46,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Tout est prêt.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _obInk,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Votre espace est configuré.\n'
                "L'IA vous attend pour écrire la suite.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: _obInk.withValues(alpha: 0.7),
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Spacer(),
            _PrimaryBtn(text: "Entrer dans l'éditeur", onTap: onComplete),
            const SizedBox(height: 10),
            _GhostBtn(text: "Revoir l'introduction", onTap: onRestart),
          ],
        ),
      ),
    );
  }
}
