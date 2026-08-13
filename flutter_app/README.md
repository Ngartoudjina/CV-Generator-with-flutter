# CV Generator — version Flutter

Portage du projet Android Kotlin / Jetpack Compose (`../app/`) vers Flutter.
Le projet Android d'origine est **intact** : rien n'a été supprimé ni modifié
en dehors de ce dossier.

## État

Portage complet et **vérifié** avec Flutter 3.44.9 / Dart 3.12.2 :

- `flutter analyze` — aucune remontée
- `flutter test` — 10 tests au vert
- Plateformes générées : `android/`, `ios/`, `web/`

## Démarrer

```bash
flutter pub get
flutter run
```

Flutter ≥ 3.27 requis (le code utilise `Color.withValues`, introduit avec
Dart 3.6).

### Aperçu dans un onglet VS Code

```bash
flutter run -d web-server --web-port=8080 --web-hostname=127.0.0.1
```

Puis `Ctrl+Shift+P` → *Simple Browser: Show* → `http://127.0.0.1:8080`.

Flutter n'a pas d'équivalent à `@Preview` de Compose : aucun rendu ne
s'affiche dans l'éditeur sans lancer l'application. Le hot reload compense —
les modifications apparaissent en moins d'une seconde sur l'app en cours
d'exécution.

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

**Débordement du Welcome.** L'écran est dense : sous ~700 px de hauteur
utile, un `Column` en `spaceBetween` rognait le contenu — la version Compose
avait le même défaut. La stratégie est désormais choisie explicitement selon
la place disponible ([welcome_screen.dart](lib/screens/welcome_screen.dart)).
Deux recettes plus élégantes ont été essayées puis écartées :
`IntrinsicHeight` sous-mesure de 44 px, car `AnimatedSwitcher` et `Transform`
ne reportent pas correctement leur hauteur intrinsèque ; et
`SliverFillRemaining` borne malgré tout le `Column` à la hauteur de la fenêtre.

**`EditorScreen` est branché sur `CvModel` — correction d'un défaut de
l'original.** `MainActivity.exportPdf()` exportait `viewModel.cvData`, alors
que `EditorScreen` éditait des `remember { mutableStateOf(...) }` locaux
jamais écrits dans le ViewModel. Dans la version Android, « Exporter PDF »
depuis l'éditeur produisait donc un CV **vide**, sans rapport avec l'écran.
Les sections Expérience et Formation étaient pires encore : valeurs figées et
`onValueChange` vide, la saisie était perdue à la frappe.

Désormais tous les champs écrivent dans `CvModel`, le panneau d'aperçu le lit,
et l'export reflète la saisie. Le contenu de démonstration d'origine sert
d'amorçage, injecté seulement si le modèle est vide — ouvrir l'éditeur
n'écrase pas un CV déjà saisi dans l'assistant.

Deux conséquences visibles :

- Le champ unique « Période » devient **Début** et **Fin**, pour alimenter
  `startDate` et `endDate` séparément.
- Le flux est à sens unique (champ → modèle). Relire le modèle à chaque
  frappe replacerait le curseur en début de texte.

`Experience.period`, `Education.years` et `Education.schoolLine` centralisent
le formatage des plages de dates, qui était dupliqué dans le PDF, l'aperçu et
l'assistant — et produisait « 2021 —  » quand la date de fin manquait.

**Thème.** `Theme.kt` déclarait un `darkColorScheme` doré alors que les écrans
principaux peignaient leurs couleurs à la main. Les deux sont conservés :
`AppTheme.light` (thème réel) et `AppTheme.legacyDark` (schéma doré, attendu
par les écrans d'étape qui lisent `Theme.of(context)`).

**Icône de lancement.** Les logos sont copiés dans `assets/images/`. L'icône de
l'application (`mipmap`) est à régénérer après `flutter create`, par exemple
avec `flutter_launcher_icons`.
