import 'package:flutter/material.dart';

import 'design_tokens.dart';

/// Thème issu de la maquette éditoriale de `maquettes/`.
///
/// Le portage Compose n'utilisait pratiquement pas son thème : chaque écran
/// peignait ses couleurs à la main, et `Theme.kt` déclarait un schéma doré que
/// personne ne lisait. Ici le thème porte réellement la typographie, les
/// surfaces et les composants — un widget non stylé doit déjà être juste.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: Accent.red,
      brightness: Brightness.light,
    ).copyWith(
      primary: Accent.red,
      onPrimary: Colors.white,
      secondary: Accent.redDeep,
      onSecondary: Colors.white,
      surface: Paper.sheet,
      onSurface: Pen.primary,
      surfaceContainerLowest: Paper.bg,
      surfaceContainerLow: Paper.tint,
      outline: Paper.ruleStrong,
      outlineVariant: Paper.rule,
      error: Status.errFg,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Paper.bg,
      fontFamily: Sans.family,
      textTheme: _textTheme,

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Accent.red,
      ),

      // Champs posés sur un aplat teinté, sans cadre permanent : la maquette
      // ne montre aucun contour au repos. Le trait n'apparaît qu'au focus,
      // là où il porte de l'information.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Paper.tint,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.lg,
        ),
        hintStyle: Sans.body.copyWith(color: Pen.faint),
        labelStyle: Mono.meta,
        floatingLabelStyle: Mono.meta.copyWith(color: Accent.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: const BorderSide(color: Accent.red, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
          borderSide: const BorderSide(color: Status.errFg, width: 1.4),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Accent.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Accent.red.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          minimumSize: const Size.fromHeight(56),
          textStyle: Sans.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Pen.primary,
          backgroundColor: Paper.sheet,
          minimumSize: const Size.fromHeight(56),
          textStyle: Sans.button,
          side: const BorderSide(color: Paper.ruleStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.md),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Accent.red,
          textStyle: Sans.button.copyWith(fontSize: 15),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Paper.rule,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Pen.primary,
        contentTextStyle: Sans.body.copyWith(color: Paper.bg, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: Paper.sheet,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: Serif.name.copyWith(fontSize: 22),
        contentTextStyle: Sans.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Paper.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Radii.sheet),
          ),
        ),
      ),

      // Material 3 teinte les surfaces avec la primaire selon l'élévation.
      // Sur un fond crème, ça vire au rose sale : on neutralise, la
      // profondeur passe par les filets.
      cardTheme: CardThemeData(
        color: Paper.sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.lg),
          side: const BorderSide(color: Paper.rule),
        ),
      ),
    );
  }

  /// Chaque rôle typographique est déjà assigné ici, pour qu'un `Text` sans
  /// style explicite tombe sur la bonne famille plutôt que sur Inter par
  /// défaut.
  static TextTheme get _textTheme => TextTheme(
        displayLarge: Serif.display,
        displayMedium: Serif.display.copyWith(fontSize: 34),
        headlineLarge: Serif.title,
        headlineMedium: Serif.name,
        titleLarge: Sans.itemTitle,
        titleMedium: Sans.entryTitle,
        titleSmall: Mono.overline,
        bodyLarge: Sans.body,
        bodyMedium: Sans.sheetBody,
        bodySmall: Mono.meta,
        labelLarge: Sans.button.copyWith(color: Pen.primary),
        labelMedium: Mono.meta,
        labelSmall: Mono.overline,
      );

  /// Schéma sombre « Gold » du portage Kotlin. Encore lu par les écrans
  /// d'étape de l'assistant ; il disparaîtra quand ceux-ci passeront à la
  /// nouvelle maquette.
  static ThemeData get legacyDark => ThemeData(
        useMaterial3: true,
        fontFamily: Sans.family,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC8A96E),
          onPrimary: Color(0xFF0A0A0F),
          surface: Color(0xFF1A1A24),
          onSurface: Color(0xFFE8E4DE),
          surfaceContainerHighest: Color(0xFF2D2D3A),
          onSurfaceVariant: Color(0xFF6B6B80),
          error: Color(0xFFCF6679),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
      );
}
