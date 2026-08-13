import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';

/// Point d'entrée — remplace `MainActivity.onCreate`.
///
/// Différence notable avec Android : `SharedPreferences` est asynchrone côté
/// Flutter, on l'ouvre donc avant de monter l'arbre de widgets pour que le
/// premier écran soit choisi immédiatement, sans flash.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barre de statut transparente : les écrans peignent leur propre dégradé
  // sombre jusqu'en haut, comme la version Compose.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  final prefs = await SharedPreferences.getInstance();

  runApp(CvGeneratorApp(prefs: prefs));
}
