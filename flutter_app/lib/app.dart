import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/cv_data.dart';
import 'models/cv_font.dart';
import 'screens/auth_screen.dart';
import 'screens/cv_wizard_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/onboarding/onboarding_flow.dart';
import 'screens/welcome_screen.dart';
import 'state/cv_library.dart';
import 'state/cv_model.dart';
import 'state/cv_storage.dart';
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
        // Le magasin des CV enregistrés, restauré depuis le disque.
        // `load()` renvoie null au tout premier lancement, ce qui laisse
        // CvLibrary poser son exemple de départ ; une liste vide signifie
        // que l'utilisateur a tout supprimé et l'exemple ne revient pas.
        ChangeNotifierProvider(
          create: (_) => CvLibrary(documents: CvStorage(prefs).load()),
        ),
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

class _AppNavigatorState extends State<AppNavigator>
    with WidgetsBindingObserver {
  late AppScreen _screen;
  late final CvModel _model;
  late final CvLibrary _library;
  late final DebouncedSaver _saver;

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

    _saver = DebouncedSaver(
      storage: CvStorage(widget.prefs),
      documents: () => _library.documents,
    );

    _model.addListener(_syncToLibrary);
    _library.addListener(_saver.schedule);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _model.removeListener(_syncToLibrary);
    _library.removeListener(_saver.schedule);
    _saver.dispose();
    super.dispose();
  }

  /// Une saisie en cours au moment où l'application passe en arrière-plan ne
  /// doit pas attendre la fin du délai d'écriture : le système peut tuer le
  /// processus avant.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saver.flush();
    }
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

  /// L'onboarding n'est plus une présentation : il remplit un vrai CV. On lui
  /// en prépare donc un neuf, pour qu'il n'écrase pas l'exemple de départ.
  void _startOnboarding() {
    _library.createNew();
    _model.load(const CvData());
    _go(const OnboardingRoute());
  }

  /// Crée un CV vierge et ouvre l'assistant dessus.
  void _createDocument() {
    _library.createNew();
    _model.load(const CvData());
    _go(const WizardRoute());
  }

  /// Déconnexion — les CV restent sur l'appareil, seul le drapeau de session
  /// est effacé. L'écran d'authentification ne vérifie rien pour l'instant,
  /// c'est donc surtout un retour au point d'entrée.
  Future<void> _signOut() async {
    await _saver.flush();
    await widget.prefs.setBool(kLoggedIn, false);
    if (mounted) _go(const AuthRoute());
  }

  /// Rejoue la présentation, comme au premier lancement.
  Future<void> _replayOnboarding() async {
    await _saver.flush();
    await widget.prefs.setBool(kOnboardingDone, false);
    if (mounted) _go(const OnboardingRoute());
  }

  /// Port de `MainActivity.exportPdf()` — l'implémentation vit dans
  /// [exportCvPdf], partagée avec l'assistant.
  Future<void> _exportPdf() => exportCvPdf(
        context,
        _model.cvData,
        font: CvFont.fromFamily(_library.current?.fontFamily),
      );

  @override
  Widget build(BuildContext context) {
    return switch (_screen) {
      WelcomeRoute() => WelcomeScreen(
          onGetStarted: _startOnboarding,
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
          onSignOut: _signOut,
          onReplayOnboarding: _replayOnboarding,
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
