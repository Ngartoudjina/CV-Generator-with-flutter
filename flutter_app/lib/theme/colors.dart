import 'package:flutter/material.dart';

/// Port de `ui/theme/Color.kt`.
/// Source d'origine : themes.js (4 palettes + surface partagée).
class AppColors {
  AppColors._();

  // ── Shared surface (light mode) ─ source: themes.js mkLight() ─
  static const Color appBg = Color(0xFFF1ECFB); // bg
  static const Color appCard = Color(0xFFFFFFFF); // surface / card
  static const Color appPaper = Color(0xFFFFFFFF); // paper
  static const Color appInk = Color(0xFF1C1626); // ink
  static const Color appInkPaper = Color(0xFF241B30); // inkPaper

  // ── Palette 1 – Violet Premium (défaut) ─ #6C40E0 ───────────
  static const Color accent = Color(0xFF6C40E0);
  static const Color accentCo = Color(0xFFC49AEC);

  // Teinte de fin des dégradés de boutons (Accent → #9B6AEE)
  static const Color accentGlow = Color(0xFF9B6AEE);

  // ── Palette 2 – Améthyste ─ #8A45C9 ─────────────────────────
  static const Color amethysteAccent = Color(0xFF8A45C9);
  static const Color amethysteCo = Color(0xFFD7A8E8);

  // ── Palette 3 – Indigo ─ #5552E6 ────────────────────────────
  static const Color indigoAccent = Color(0xFF5552E6);
  static const Color indigoCo = Color(0xFF9AA6F2);

  // ── Palette 4 – Mauve ─ #A24BBE ─────────────────────────────
  static const Color mauveAccent = Color(0xFFA24BBE);
  static const Color mauveCo = Color(0xFFE6A6D8);

  // ── Fond sombre partagé (Welcome / Auth / Dashboard / Editor) ─
  static const Color dark = Color(0xFF0D0920);
  static const Color darkMid = Color(0xFF180C30);
  static const Color white = Color(0xFFEFEBFF);
  static const Color inkSub = Color(0xFFBBB0D8);

  // ── Welcome screen light theme (buildTheme light) ────────────
  static const Color welcomeBg = Color(0xFFF6F4FC);
  static const Color welcomeInk = Color(0xFF191525);
  static const Color welcomeInkPaper = Color(0xFF221A2E);

  // ── Sémantique ───────────────────────────────────────────────
  static const Color errorRed = Color(0xFFCF6679);
  static const Color successGreen = Color(0xFF4CAF87);
  static const Color warnOrange = Color(0xFFF5A623);
  static const Color warnLime = Color(0xFF85BB65);

  // ── Legacy (ancien thème sombre — conservé pour compatibilité) ─
  static const Color deepBlack = Color(0xFF0A0A0F);
  static const Color cream = Color(0xFFF5F2ED);
  static const Color gold = Color(0xFFC8A96E);
  static const Color goldLight = Color(0xFFD4B97E);
  static const Color darkGray = Color(0xFF1A1A24);
  static const Color mediumGray = Color(0xFF2D2D3A);
  static const Color lightGray = Color(0xFF6B6B80);
  static const Color textLight = Color(0xFFE8E4DE);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ── Dégradés réutilisés ──────────────────────────────────────
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentGlow],
  );

  static const LinearGradient accentCoGradient = LinearGradient(
    colors: [accent, accentCo],
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [dark, darkMid, Color(0x000D0920)],
  );
}
