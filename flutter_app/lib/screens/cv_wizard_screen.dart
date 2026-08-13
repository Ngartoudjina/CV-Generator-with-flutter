import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cv_model.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../utils/pdf_export.dart';
import '../widgets/step_progress_bar.dart';
import 'steps/education_screen.dart';
import 'steps/experience_screen.dart';
import 'steps/personal_info_screen.dart';
import 'steps/preview_screen.dart';
import 'steps/skills_screen.dart';

/// Hôte de l'assistant de création en 5 étapes.
///
/// Ce fichier n'existe pas dans le projet Kotlin : `CvViewModel`,
/// `StepProgressBar` et les cinq écrans d'étape y étaient écrits mais jamais
/// assemblés — `MainActivity` ne les référençait pas. Il fournit le châssis
/// manquant, sans rien changer aux écrans eux-mêmes.
///
/// Les écrans d'étape lisent `Theme.of(context)` en attendant le schéma sombre
/// « Gold » d'origine (`DarkColorScheme` de Theme.kt) ; on le réinjecte donc
/// localement plutôt que de le laisser hériter du thème violet clair de l'app.
class CvWizardScreen extends StatefulWidget {
  const CvWizardScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<CvWizardScreen> createState() => _CvWizardScreenState();
}

class _CvWizardScreenState extends State<CvWizardScreen> {
  /// L'assistant repart toujours de la première étape à l'ouverture — le
  /// `currentStep` du modèle survit à la navigation.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CvModel>().goToStep(0);
    });
  }

  /// Les trois champs marqués « * » dans `PersonalInfoScreen`. C'est la seule
  /// règle de validation de l'assistant : on ne quitte pas l'étape Identité
  /// tant qu'elle n'est pas satisfaite. Aucune autre étape n'est bloquante.
  bool _identityComplete(CvModel model) {
    final info = model.cvData.personalInfo;
    return info.fullName.trim().isNotEmpty &&
        info.jobTitle.trim().isNotEmpty &&
        info.email.trim().isNotEmpty;
  }

  void _goToStep(CvModel model, int target) {
    if (target == model.currentStep) return;

    if (model.currentStep == 0 && target > 0 && !_identityComplete(model)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Renseignez le nom, le titre et l\'email pour continuer.',
          ),
        ),
      );
      return;
    }

    model.goToStep(target);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final step = model.currentStep;
    final isLast = step == CvModel.totalSteps - 1;

    return Theme(
      data: AppTheme.legacyDark,
      child: Scaffold(
        backgroundColor: AppColors.deepBlack,
        body: SafeArea(
          child: Column(
            children: [
              _WizardHeader(onBack: widget.onBack, step: step),

              StepProgressBar(
                currentStep: step,
                totalSteps: CvModel.totalSteps,
                onStepClick: (i) => _goToStep(model, i),
              ),

              const Divider(height: 1, color: AppColors.mediumGray),

              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(step),
                    child: switch (step) {
                      0 => const PersonalInfoScreen(),
                      1 => const ExperienceScreen(),
                      2 => const EducationScreen(),
                      3 => const SkillsScreen(),
                      _ => PreviewScreen(
                          onExportPdf: () =>
                              exportCvPdf(context, model.cvData),
                        ),
                    },
                  ),
                ),
              ),

              _WizardFooter(
                step: step,
                isLast: isLast,
                canAdvance: step != 0 || _identityComplete(model),
                onPrevious: model.previousStep,
                onNext: () => _goToStep(model, step + 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── En-tête ──────────────────────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({required this.onBack, required this.step});

  final VoidCallback onBack;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: AppColors.cream),
            tooltip: 'Retour',
          ),
          const Expanded(
            child: Text(
              'Nouveau CV',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.cream,
              ),
            ),
          ),
          Text(
            'Étape ${step + 1} / ${CvModel.totalSteps}',
            style: const TextStyle(fontSize: 12, color: AppColors.lightGray),
          ),
        ],
      ),
    );
  }
}

// ── Pied de page : navigation entre étapes ───────────────────────────────────

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({
    required this.step,
    required this.isLast,
    required this.canAdvance,
    required this.onPrevious,
    required this.onNext,
  });

  final int step;
  final bool isLast;
  final bool canAdvance;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkGray,
        border: Border(top: BorderSide(color: AppColors.mediumGray)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: onPrevious,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: AppColors.cream,
                  side: const BorderSide(color: AppColors.mediumGray),
                ),
                child: const Text('Précédent'),
              ),
            ),

          if (step > 0 && !isLast) const SizedBox(width: 12),

          // Sur la dernière étape, l'export est déclenché par le bouton déjà
          // présent dans `PreviewScreen` — pas de second appel à l'action ici.
          if (!isLast)
            Expanded(
              child: FilledButton(
                onPressed: canAdvance ? onNext : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.deepBlack,
                  disabledBackgroundColor:
                      AppColors.gold.withValues(alpha: 0.35),
                  disabledForegroundColor:
                      AppColors.deepBlack.withValues(alpha: 0.45),
                ),
                child: const Text(
                  'Suivant',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
