# CV Generator — version Flutter

Portage du projet Android Kotlin / Jetpack Compose (`../app/`) vers Flutter.
Le projet Android d'origine est **intact** : rien n'a été supprimé ni modifié
en dehors de ce dossier.

## État

Tout le code Dart est écrit (`lib/`, 100 % du Kotlin porté). Il manque
uniquement les dossiers de plateforme (`android/`, `ios/`), qui ne peuvent pas
être écrits à la main — ils sont générés par l'outil `flutter`, qui **n'est pas
installé sur cette machine**. Voir « Finalisation » ci-dessous.

> ⚠️ Le code n'a donc pas encore été compilé ni exécuté. La première
> exécution de `flutter analyze` révélera probablement quelques ajustements
> mineurs (imports, `const`) — c'est normal pour un portage de cette taille.

## Installation de Flutter (Windows)

1. Télécharger le SDK : <https://docs.flutter.dev/get-started/install/windows>
2. Décompresser dans `C:\src\flutter` (éviter les chemins avec espaces ou
   `Program Files`).
3. Ajouter `C:\src\flutter\bin` au `PATH`.
4. Vérifier : `flutter doctor`

Android Studio est déjà installé avec le SDK Android — `flutter doctor` devrait
le détecter. Il faudra accepter les licences : `flutter doctor --android-licenses`,
et installer le plugin Flutter dans Android Studio.

## Finalisation

Depuis `flutter_app/`, générer les dossiers de plateforme sans écraser le code
porté :

```bash
# 1. Mettre le code porté à l'abri (flutter create réécrit lib/main.dart)
mv lib lib_port

# 2. Générer android/, ios/, et les fichiers manquants
flutter create --platforms=android,ios --org com.cvgenerator --project-name cvgenerator .

# 3. Restaurer le code porté
rm -rf lib && mv lib_port lib

# 4. Dépendances puis contrôle statique
flutter pub get
flutter analyze

# 5. Lancer
flutter run
```

## Correspondance des fichiers

| Kotlin (`app/src/main/java/com/cvgenerator/`) | Dart (`lib/`) |
|---|---|
| `MainActivity.kt` | `main.dart` + `app.dart` |
| `ui/theme/Color.kt` | `theme/colors.dart` |
| `ui/theme/Theme.kt` | `theme/app_theme.dart` |
| `data/CvData.kt` | `models/cv_data.dart` |
| `data/CvViewModel.kt` | `state/cv_model.dart` |
| `ui/anim/AnimUtils.kt` | `utils/anim.dart` |
| `ui/components/StepProgressBar.kt` | `widgets/step_progress_bar.dart` |
| `ScoreRingSmall` (dans DashboardScreen.kt) | `widgets/score_ring.dart` |
| `ui/screens/WelcomeScreen.kt` | `screens/welcome_screen.dart` |
| `ui/screens/AuthScreen.kt` | `screens/auth_screen.dart` |
| `ui/screens/DashboardScreen.kt` | `screens/dashboard_screen.dart` |
| `ui/screens/EditorScreen.kt` | `screens/editor_screen.dart` |
| `ui/onboarding/OnboardingScreen.kt` | `screens/onboarding/onboarding_flow.dart` |
| `ui/screens/PersonalInfoScreen.kt` | `screens/steps/personal_info_screen.dart` |
| `ui/screens/ExperienceScreen.kt` | `screens/steps/experience_screen.dart` |
| `ui/screens/EducationScreen.kt` | `screens/steps/education_screen.dart` |
| `ui/screens/SkillsScreen.kt` | `screens/steps/skills_screen.dart` |
| `ui/screens/PreviewScreen.kt` | `screens/steps/preview_screen.dart` |
| `pdf/PdfGenerator.kt` | `pdf/pdf_generator.dart` |
| `MainActivity.exportPdf()` | `utils/pdf_export.dart` |
| *(sans équivalent)* | `screens/cv_wizard_screen.dart` |

## Équivalences techniques

| Compose | Flutter |
|---|---|
| `@Composable fun` | `Widget` |
| `remember { mutableStateOf() }` | `State` + `setState` |
| `MutableStateFlow` / `collectAsState()` | `ChangeNotifier` + `provider` |
| `LaunchedEffect` + `delay` | `initState` + `Timer` |
| `rememberInfiniteTransition` | `AnimationController(...)..repeat()` |
| `animateFloatAsState` | `AnimatedFoo` / `TweenAnimationBuilder` |
| `spring(DampingRatioMediumBouncy)` | `Curves.easeOutBack` (`kBouncy`) |
| `Modifier.clickable` + `collectIsPressedAsState` | `PressScale` (`utils/anim.dart`) |
| `TextStyle(brush = Brush.linearGradient)` | `GradientText` (`ShaderMask`) |
| `Modifier.border(w, Brush, Shape)` | `GradientBorder` (pas d'équivalent natif) |
| `FlowRow` | `Wrap` |
| `LazyColumn` | `ListView.builder` |
| `Canvas` + `drawArc` | `CustomPainter` |
| `SharedPreferences` | `shared_preferences` (asynchrone) |
| `android.graphics.pdf.PdfDocument` | package `pdf` (par widgets) |
| `FileProvider` + `Intent.ACTION_VIEW` | `Printing.sharePdf` |

## Points d'attention

**Ressorts d'animation.** Compose utilise un solveur physique
(`spring(dampingRatio, stiffness)`) que Flutter n'expose pas en animation
implicite. Toutes les animations « élastiques » utilisent `Curves.easeOutBack`,
qui reproduit le léger dépassement mais n'est pas mathématiquement identique.
Si le rendu semble trop sec ou trop mou, ajuster `kBouncy` dans
[utils/anim.dart](lib/utils/anim.dart) — un seul point à modifier.

**Générateur PDF.** C'est la seule partie réellement réécrite plutôt que
traduite. La version Kotlin positionnait chaque `drawText` au point près et
calculait ses retours à la ligne à la main ; la version Dart décrit des
widgets. Conséquence positive : le CV **passe désormais sur plusieurs pages**
si le contenu déborde, ce que la version Android tronquait silencieusement.

**Assistant en 5 étapes.** Dans le projet Kotlin, `screens/steps/`, `CvViewModel`
et `StepProgressBar` existaient mais n'étaient assemblés nulle part —
`MainActivity` ne les référençait pas. Le châssis manquant a été ajouté :
[cv_wizard_screen.dart](lib/screens/cv_wizard_screen.dart). C'est le seul
fichier sans équivalent Kotlin ; les cinq écrans d'étape, eux, n'ont pas été
modifiés.

- **Point d'entrée** — « Créer un nouveau CV » (Dashboard) ouvre l'assistant.
  Ouvrir un CV existant continue d'ouvrir `EditorScreen`. Auparavant les deux
  menaient à l'éditeur, `onCreateNew` passant simplement `cvId = 0`.
- **Validation** — une seule règle : on ne quitte pas l'étape *Identité* tant
  que nom, titre et email ne sont pas remplis. Ce sont les trois champs déjà
  marqués `*` dans `PersonalInfoScreen` ; aucune contrainte n'a été inventée
  au-delà. Les autres étapes sont librement navigables, y compris en cliquant
  les pastilles de `StepProgressBar`.
- **Export** — déclenché par le bouton déjà présent dans `PreviewScreen`. Le
  pied de page de l'assistant n'ajoute pas de second appel à l'action.
- **Thème** — l'assistant réinjecte `AppTheme.legacyDark`, car les écrans
  d'étape lisent `Theme.of(context)` en attendant le schéma doré d'origine.

**Incohérence héritée de l'original — `EditorScreen` et l'export.**
`MainActivity.exportPdf()` exportait `viewModel.cvData`, alors que
`EditorScreen` éditait des `remember { mutableStateOf(...) }` locaux jamais
écrits dans le ViewModel. Autrement dit : dans la version Android, « Exporter
PDF » depuis l'éditeur produisait un CV **vide**, sans rapport avec ce qui
était affiché à l'écran. Le portage reproduit ce comportement à l'identique
plutôt que de le corriger en douce.

L'assistant, lui, n'a pas ce problème : il écrit dans `CvModel`, donc son
export reflète bien la saisie. Corriger l'éditeur suppose de brancher ses
champs sur `CvModel` — un vrai changement de comportement, à décider.

**Thème.** `Theme.kt` déclarait un `darkColorScheme` doré alors que les écrans
principaux peignaient leurs couleurs à la main. Les deux sont conservés :
`AppTheme.light` (thème réel) et `AppTheme.legacyDark` (schéma doré, attendu
par les écrans d'étape qui lisent `Theme.of(context)`).

**Icône de lancement.** Les logos sont copiés dans `assets/images/`. L'icône de
l'application (`mipmap`) est à régénérer après `flutter create`, par exemple
avec `flutter_launcher_icons`.
