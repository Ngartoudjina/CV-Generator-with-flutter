import 'package:flutter/material.dart';

import 'colors.dart';

/// Port de `ui/theme/Theme.kt`.
///
/// Le projet Compose déclarait un unique `darkColorScheme` (palette Gold
/// legacy) alors que les écrans principaux peignaient leurs couleurs à la
/// main. On garde les deux :
///
/// * [AppTheme.light]      — thème réel de l'app (surface violette claire).
/// * [AppTheme.legacyDark] — schéma Gold d'origine, utilisé uniquement par les
///   écrans d'étape (`screens/steps/`) qui lisent `Theme.of(context)`.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accentCo,
      onSecondary: Colors.white,
      surface: AppColors.appCard,
      onSurface: AppColors.appInk,
      error: AppColors.errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.appBg,
      fontFamily: null, // police système — identique au comportement Compose
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8F5FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide:
              BorderSide(color: AppColors.appInk.withValues(alpha: 0.11)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide:
              BorderSide(color: AppColors.appInk.withValues(alpha: 0.11)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.6),
        ),
      ),
    );
  }

  /// Schéma sombre « Gold » d'origine (`DarkColorScheme` dans Theme.kt).
  static ThemeData get legacyDark {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        onPrimary: AppColors.deepBlack,
        secondary: AppColors.goldLight,
        onSecondary: AppColors.deepBlack,
        surface: AppColors.darkGray,
        onSurface: AppColors.textLight,
        surfaceContainerHighest: AppColors.mediumGray,
        onSurfaceVariant: AppColors.lightGray,
        error: AppColors.errorRed,
        outline: AppColors.mediumGray,
      ),
      scaffoldBackgroundColor: AppColors.deepBlack,
    );
  }
}
