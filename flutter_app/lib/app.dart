import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/cv_data.dart';
import 'screens/auth_screen.dart';
import 'screens/cv_wizard_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/welcome_screen.dart';
import 'state/cv_library.dart';
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

  /// Identifiant du document dans [CvLibrary] — la version Kotlin passait un
  /// `Int` provenant d'une liste figée.
  final String cvId;
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
    return MultiProvider(
      providers: [
        // Le magasin des CV enregistrés…
        ChangeNotifierProvider(create: (_) => CvLibrary()),
        // …et la copie de travail éditée par l'assistant et l'éditeur.
        ChangeNotifierProvider(create: (_) => CvModel()),
      ],
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
  late final CvModel _model;
  late final CvLibrary _library;

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

    _model = context.read<CvModel>();
    _library = context.read<CvLibrary>();
    _model.addListener(_syncToLibrary);
  }

  @override
  void dispose() {
    _model.removeListener(_syncToLibrary);
    super.dispose();
  }

  /// Toute modification de la copie de travail est enregistrée dans le
  /// document courant de la bibliothèque. C'est le seul point de couplage
  /// entre les deux : les écrans n'ont pas à y penser.
  void _syncToLibrary() => _library.updateCurrent(_model.cvData);

  void _go(AppScreen next) => setState(() => _screen = next);

  /// Ouvre un CV enregistré : on le désigne comme courant, puis on charge son
  /// contenu dans la copie de travail.
  void _openDocument(String id) {
    _library.open(id);
    final doc = _library.current;
    if (doc != null) _model.load(doc.data);
    _go(EditorRoute(id));
  }

  /// Crée un CV vierge et ouvre l'assistant dessus.
  void _createDocument() {
    _library.createNew();
    _model.load(const CvData());
    _go(const WizardRoute());
  }

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
          onOpenEditor: _openDocument,
          onCreateNew: _createDocument,
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
