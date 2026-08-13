import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Port de `ui/components/StepProgressBar.kt`.
const List<String> stepLabels = [
  'Identité',
  'Expériences',
  'Formation',
  'Compétences',
  'Aperçu',
];

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onStepClick,
  });

  final int currentStep;
  final int totalSteps;
  final ValueChanged<int> onStepClick;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final children = <Widget>[];

    for (var index = 0; index < totalSteps; index++) {
      final isCompleted = index < currentStep;
      final isCurrent = index == currentStep;
      final color =
          (isCompleted || isCurrent) ? AppColors.gold : AppColors.mediumGray;

      children.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => onStepClick(index),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  isCompleted ? '✓' : '${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: (isCompleted || isCurrent)
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              index < stepLabels.length ? stepLabels[index] : '',
              style: TextStyle(
                fontSize: 9,
                color: isCurrent ? AppColors.gold : scheme.onSurfaceVariant,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      );

      if (index < totalSteps - 1) {
        children.add(
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 2,
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: ColoredBox(color: AppColors.mediumGray),
                    ),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 300),
                      widthFactor: index < currentStep ? 1 : 0,
                      alignment: Alignment.centerLeft,
                      child: const ColoredBox(color: AppColors.gold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }
}
