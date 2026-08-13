# CV Generator

Générateur de CV assisté par IA. Le dépôt contient **deux bases de code** :
l'application Android d'origine et son portage Flutter.

| Dossier | Stack | État |
|---|---|---|
| [`app/`](app/) | Kotlin · Jetpack Compose | Fonctionnel, tous les écrans implémentés |
| [`flutter_app/`](flutter_app/) | Dart · Flutter | Portage complet, pas encore compilé |

Le portage Flutter a été motivé par la cible iOS : le projet Compose était
encore assez petit pour que la réécriture soit rentable.

## Fonctionnalités

Parcours Welcome → Onboarding → Authentification → Tableau de bord → Éditeur,
plus un assistant de création en 5 étapes (identité, expériences, formation,
compétences, aperçu) et un export PDF compatible ATS.

Le design suit quatre palettes dérivées de `themes.js` — Violet Premium
(défaut), Améthyste, Indigo et Mauve — sur une surface claire commune.

## Démarrer

### Version Flutter

```bash
cd flutter_app
flutter pub get
flutter run
```

Flutter ≥ 3.27 requis. Les dossiers `android/` et `ios/` doivent être générés
au premier clone — la procédure est dans [flutter_app/README.md](flutter_app/README.md),
section « Finalisation ».

### Version Android

Ouvrir la racine du dépôt dans Android Studio. Le wrapper Gradle n'est pas
versionné : Android Studio le régénérera, ou `gradle wrapper` en ligne de
commande.

## Documentation

[flutter_app/README.md](flutter_app/README.md) détaille la migration :
correspondance fichier par fichier entre Kotlin et Dart, table d'équivalences
Compose ↔ Flutter, et les écarts assumés par rapport à l'original — notamment
la réécriture du générateur PDF et le câblage de l'assistant en 5 étapes, qui
existait côté Kotlin sans jamais être assemblé.
