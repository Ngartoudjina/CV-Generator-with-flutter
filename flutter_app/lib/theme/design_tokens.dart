import 'package:flutter/material.dart';

/// Jetons de design — maquette « éditoriale » de `maquettes/`.
///
/// Rupture assumée avec le portage Compose, qui était violet, sombre et
/// glassmorphique. La nouvelle direction est celle de l'imprimé : fond crème,
/// accent rouge brique, filets fins, aucune ombre diffuse.
///
/// Trois familles de caractères, chacune avec un rôle strict :
///
/// * **Playfair Display** — titres uniquement. Serif à fort contraste, c'est
///   lui qui donne le ton éditorial.
/// * **JetBrains Mono** — toute la métadonnée d'interface : sur-titres, dates,
///   compteurs, badges, libellés de section. C'est l'emploi du monospace comme
///   signal, et non comme police de code, qui fait le caractère de la maquette.
/// * **Inter** — corps de texte et intitulés. Neutre, lisible, il s'efface.
///
/// Mélanger ces rôles casse l'ensemble : une date en Inter ou un titre en
/// mono, et l'identité disparaît.

// ── Palette ──────────────────────────────────────────────────────────────

abstract final class Paper {
  /// Fond de l'application — crème chaud, pas un gris.
  static const Color bg = Color(0xFFF5F2ED);

  /// Feuille de CV, cartes et surfaces surélevées.
  static const Color sheet = Color(0xFFFFFFFF);

  /// Bande légèrement teintée : en-têtes de groupe, zones inertes.
  static const Color tint = Color(0xFFEFEBE4);

  /// Filet de séparation. Un trait, pas une ombre.
  static const Color rule = Color(0xFFDFD9D0);

  /// Filet plus marqué, pour les contours de carte.
  static const Color ruleStrong = Color(0xFFCFC7BB);
}

abstract final class Pen {
  /// Texte principal — presque noir, légèrement chaud.
  static const Color primary = Color(0xFF1A1714);

  /// Texte secondaire.
  static const Color secondary = Color(0xFF6E675E);

  /// Métadonnée, mentions discrètes.
  static const Color muted = Color(0xFF9A9288);

  /// Texte désactivé ou fantôme.
  static const Color faint = Color(0xFFBDB5A9);
}

abstract final class Accent {
  /// Rouge brique — la couleur d'action et d'emphase.
  static const Color red = Color(0xFFC0392B);

  /// Variante foncée, pour le texte sur fond clair teinté.
  static const Color redDeep = Color(0xFF9E2B1E);

  /// Fond de surlignage et zones d'accent très diluées.
  static const Color redWash = Color(0xFFFBEDE9);

  /// Contour d'une zone d'accent.
  static const Color redLine = Color(0xFFE8BFB6);
}

/// États — verts et ambres désaturés, accordés au crème.
abstract final class Status {
  static const Color okFg = Color(0xFF2F6B4F);
  static const Color okBg = Color(0xFFE8F0EA);

  static const Color warnFg = Color(0xFF8A6A1F);
  static const Color warnBg = Color(0xFFF6EEDC);

  static const Color errFg = Color(0xFF9E2B1E);
  static const Color errBg = Color(0xFFFBEDE9);
}

// ── Typographie ──────────────────────────────────────────────────────────

abstract final class Serif {
  static const String family = 'PlayfairDisplay';

  /// Titre d'accroche — « Le CV qui vous fait remarquer. »
  static const TextStyle display = TextStyle(
    fontFamily: family,
    fontSize: 40,
    height: 1.12,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.5,
    color: Pen.primary,
  );

  /// Titre d'écran — « Mes CV », « Sections ».
  static const TextStyle title = TextStyle(
    fontFamily: family,
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.3,
    color: Pen.primary,
  );

  /// Nom sur la feuille de CV.
  static const TextStyle name = TextStyle(
    fontFamily: family,
    fontSize: 21,
    height: 1.2,
    fontWeight: FontWeight.w500,
    color: Pen.primary,
  );
}

abstract final class Mono {
  static const String family = 'JetBrainsMono';

  /// Sur-titre de section, en capitales espacées.
  static const TextStyle overline = TextStyle(
    fontFamily: family,
    fontSize: 9.5,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.6,
    color: Pen.muted,
  );

  /// Même usage, mais en accent — « PRODUCT DESIGNER » dans les groupes.
  static const TextStyle overlineAccent = TextStyle(
    fontFamily: family,
    fontSize: 9.5,
    height: 1.2,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.6,
    color: Accent.red,
  );

  /// Métadonnée courante — « Modifié il y a 2 h · modèle Ravel ».
  ///
  /// 11 dp et non 13 : le monospace est large, et à 13 la ligne complète de
  /// la maquette se fait tronquer sur un écran de 393 dp.
  static const TextStyle meta = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 1.35,
    fontWeight: FontWeight.w400,
    color: Pen.muted,
  );

  /// Dates sur la feuille de CV.
  static const TextStyle date = TextStyle(
    fontFamily: family,
    fontSize: 9.5,
    height: 1.3,
    fontWeight: FontWeight.w400,
    color: Pen.muted,
  );

  /// Badge — « COMPLET », « À TERMINER », « EN COURS ».
  static const TextStyle badge = TextStyle(
    fontFamily: family,
    fontSize: 11,
    height: 1.1,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
  );

  /// Numéro de section — « 01 », « 02 ».
  static const TextStyle index = TextStyle(
    fontFamily: family,
    fontSize: 13,
    height: 1,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: Accent.red,
  );

  /// Score ATS. Chiffres tabulaires : la largeur ne bouge pas pendant
  /// l'animation du compteur.
  static const TextStyle score = TextStyle(
    fontFamily: family,
    fontSize: 17,
    height: 1,
    fontWeight: FontWeight.w700,
    color: Pen.primary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

abstract final class Sans {
  static const String family = 'Inter';

  /// Intitulé d'élément — « Ovalis — candidature spontanée ».
  static const TextStyle itemTitle = TextStyle(
    fontFamily: family,
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: Pen.primary,
  );

  /// Nom de section dans la feuille — « Lead Designer — Ovalis ».
  static const TextStyle entryTitle = TextStyle(
    fontFamily: family,
    fontSize: 12.5,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: Pen.primary,
  );

  /// Corps de texte.
  static const TextStyle body = TextStyle(
    fontFamily: family,
    fontSize: 15,
    height: 1.55,
    fontWeight: FontWeight.w400,
    color: Pen.secondary,
  );

  /// Corps sur la feuille de CV.
  ///
  /// 12,5 px et non 13,5 : à la taille supérieure, une puce comme « Refonte
  /// du parcours d'abonnement sur iOS et Android. » passe à la ligne, alors
  /// que la maquette la tient sur une seule. C'est cette densité qui fait
  /// lire la carte comme un document plutôt que comme une interface.
  static const TextStyle sheetBody = TextStyle(
    fontFamily: family,
    fontSize: 10.5,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: Pen.secondary,
  );

  /// Libellé de bouton.
  static const TextStyle button = TextStyle(
    fontFamily: family,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );
}

// ── Géométrie ────────────────────────────────────────────────────────────

abstract final class Radii {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double sheet = 24;
  static const double full = 999;
}

abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double xxxl = 40;
}

/// Ombres très retenues. Dans cette maquette la profondeur vient des filets
/// et du contraste crème/blanc, pas du flou : une seule ombre douce sous la
/// feuille de CV et les éléments flottants.
abstract final class Shadow {
  static List<BoxShadow> get sheet => const [
        BoxShadow(
          color: Color(0x0F1A1714),
          blurRadius: 24,
          offset: Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get floating => const [
        BoxShadow(
          color: Color(0x33C0392B),
          blurRadius: 20,
          offset: Offset(0, 6),
        ),
      ];
}

abstract final class Motion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration slow = Duration(milliseconds: 420);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
}
