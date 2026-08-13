import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/auth_screen.dart';
import 'screens/cv_wizard_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/welcome_screen.dart';
import 'state/cv_model.dart';
import 'theme/app_theme.dart';
import 'utils/pdf_export.dart';

/// Port de la `sealed class AppScreen` de MainActivity.kt.
sealed class AppScreen {
  const AppScreen();
}

class WelcomeRoute extends AppScreen {
  const WelcomeRoute();
}

class OnboardingRoute extends AppScreen {
  const OnboardingRoute();
}

class AuthRoute extends AppScreen {
  const AuthRoute();
}

class DashboardRoute extends AppScreen {
  const DashboardRoute();
}

/// Assistant de création en 5 étapes — n'existait pas dans MainActivity.kt,
/// où « Créer un nouveau CV » ouvrait l'éditeur de démonstration avec
/// `cvId = 0`. Voir [CvWizardScreen].
class WizardRoute extends AppScreen {
  const WizardRoute();
}

class EditorRoute extends AppScreen {
  const EditorRoute(this.cvId);

  final int cvId;
}

/// Clés SharedPreferences — identiques à celles de la version Android
/// (`getSharedPreferences("cvgen", MODE_PRIVATE)`).
const String kOnboardingDone = 'onboarding_done';
const String kLoggedIn = 'logged_in';

class CvGeneratorApp extends StatelessWidget {
  const CvGeneratorApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CvModel(),
      child: MaterialApp(
        title: 'CV Generator',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: AppNavigator(prefs: prefs),
      ),
    );
  }
}

/// Port du `when (val s = screen) { … }` de MainActivity.onCreate.
class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  late AppScreen _screen;

  @override
  void initState() {
    super.initState();
    final onboardingDone = widget.prefs.getBool(kOnboardingDone) ?? false;
    final loggedIn = widget.prefs.getBool(kLoggedIn) ?? false;

    _screen = switch ((onboardingDone, loggedIn)) {
      (false, _) => const WelcomeRoute(),
      (true, false) => const AuthRoute(),
      (true, true) => const DashboardRoute(),
    };
  }

  void _go(AppScreen next) => setState(() => _screen = next);

  /// Port de `MainActivity.exportPdf()` — l'implémentation vit dans
  /// [exportCvPdf], partagée avec l'assistant.
  Future<void> _exportPdf() =>
      exportCvPdf(context, context.read<CvModel>().cvData);

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      WelcomeRoute() => WelcomeScreen(
          onGetStarted: () => _go(const OnboardingRoute()),
          onLogin: () => _go(const AuthRoute()),
        ),
      OnboardingRoute() => OnboardingFlow(
          onComplete: () async {
            await widget.prefs.setBool(kOnboardingDone, true);
            if (mounted) _go(const AuthRoute());
          },
        ),
      AuthRoute() => AuthScreen(
          onAuthSuccess: () async {
            await widget.prefs.setBool(kLoggedIn, true);
            if (mounted) _go(const DashboardRoute());
          },
          onBack: () => _go(
            (widget.prefs.getBool(kOnboardingDone) ?? false)
                ? const WelcomeRoute()
                : const OnboardingRoute(),
          ),
        ),
      DashboardRoute() => DashboardScreen(
          // Ouvrir un CV existant → éditeur ; en créer un → assistant.
          onOpenEditor: (cvId) => _go(EditorRoute(cvId)),
          onCreateNew: () => _go(const WizardRoute()),
          onProfile: () {},
        ),
      WizardRoute() => CvWizardScreen(
          onBack: () => _go(const DashboardRoute()),
        ),
      EditorRoute(cvId: final id) => EditorScreen(
          cvId: id,
          onBack: () => _go(const DashboardRoute()),
          onExport: _exportPdf,
        ),
    };
  }
}
