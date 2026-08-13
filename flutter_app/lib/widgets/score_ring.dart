import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../utils/anim.dart';

/// Port de `ScoreRingSmall` (DashboardScreen.kt) — anneau de score ATS
/// avec halo pulsé, piste de fond et arc en dégradé balayé.
class ScoreRingSmall extends StatelessWidget {
  const ScoreRingSmall({super.key, required this.score, this.size = 46});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: PulseBuilder(
        min: 0.12,
        max: 0.38,
        duration: const Duration(milliseconds: 1600),
        builder: (context, glowAlpha) {
          return AnimatedIntBuilder(
            value: score,
            duration: const Duration(milliseconds: 1000),
            builder: (context, current) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size.square(size),
                    painter: _ScoreRingPainter(
                      progress: current / 100,
                      glowAlpha: glowAlpha,
                    ),
                  ),
                  GradientText(
                    '$current',
                    gradient: AppColors.accentCoGradient,
                    style: TextStyle(
                      fontSize: size * 0.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({required this.progress, required this.glowAlpha});

  final double progress;
  final double glowAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final sweep = progress * 2 * math.pi;
    const startAngle = -math.pi / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(4);

    // Halo extérieur
    canvas.drawArc(
      rect,
      startAngle,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = AppColors.accent.withValues(alpha: glowAlpha),
    );

    // Piste
    canvas.drawArc(
      rect,
      startAngle,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = AppColors.appInk.withValues(alpha: 0.08),
    );

    // Arc de progression en dégradé balayé
    canvas.drawArc(
      rect,
      startAngle,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [AppColors.accent, AppColors.accentCo, AppColors.accent],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.glowAlpha != glowAlpha;
}

/// Grand anneau de score utilisé par l'écran d'onboarding « 02 · Score ».
class ScoreRingLarge extends StatelessWidget {
  const ScoreRingLarge({super.key, required this.score, this.size = 180});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedIntBuilder(
        value: score,
        duration: const Duration(milliseconds: 1400),
        builder: (context, current) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _LargeRingPainter(progress: current / 100),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$current',
                    style: const TextStyle(
                      fontSize: 52,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.appInk,
                    ),
                  ),
                  Text(
                    '/ 100',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.appInk.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LargeRingPainter extends CustomPainter {
  _LargeRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(12);
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      rect,
      startAngle,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = AppColors.appInk.withValues(alpha: 0.08),
    );

    canvas.drawArc(
      rect,
      startAngle,
      progress * 2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [
            AppColors.accent,
            AppColors.accentCo,
            AppColors.accentGlow,
            AppColors.accent,
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_LargeRingPainter old) => old.progress != progress;
}
