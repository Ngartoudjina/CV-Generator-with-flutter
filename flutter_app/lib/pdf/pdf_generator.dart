import 'dart:typed_data';

// `package:meta` plutôt que `flutter/foundation` : ce fichier n'a aucune
// dépendance à Flutter, ce qui le rend exécutable en Dart pur.
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/cv_data.dart';

/// Réécriture de `pdf/PdfGenerator.kt`.
///
/// L'original dessinait sur un `android.graphics.Canvas` (`drawText`,
/// `drawRect`, retour à la ligne calculé à la main via `measureText`). Le
/// package `pdf` de Flutter travaille par widgets : la mise en page, le retour
/// à la ligne et la pagination sont gérés automatiquement — plus besoin de
/// `drawWrappedText`, et le CV déborde proprement sur une seconde page si
/// nécessaire (ce que la version Android ne savait pas faire).
class PdfGenerator {
  PdfGenerator._();

  // Palette du CV exporté — reprise à l'identique de la version Kotlin.
  static const _ink = PdfColor.fromInt(0xFF0A0A0F);
  static const _cream = PdfColor.fromInt(0xFFF5F2ED);
  static const _gold = PdfColor.fromInt(0xFFC8A96E);
  static const _contact = PdfColor.fromInt(0xFFAAAAAA);
  static const _body = PdfColor.fromInt(0xFF333333);
  static const _sub = PdfColor.fromInt(0xFF555555);
  static const _date = PdfColor.fromInt(0xFF888888);
  static const _strong = PdfColor.fromInt(0xFF111111);
  static const _barBg = PdfColor.fromInt(0xFFDDDDDD);

  static const double _margin = 40;

  /// Nom de fichier proposé au partage.
  static String fileName(CvData cvData) {
    final name = cvData.personalInfo.fullName.trim();
    return 'CV_${name.isEmpty ? "Sans_nom" : name.replaceAll(" ", "_")}.pdf';
  }

  /// Construit le document et renvoie ses octets.
  ///
  /// Volontairement sans écriture disque : la version Kotlin passait par un
  /// fichier parce que `Intent.ACTION_VIEW` exigeait une URI de FileProvider.
  /// `Printing.sharePdf` prend les octets directement, ce qui supprime la
  /// dépendance à `dart:io` — et donc rend la cible web compilable.
  static Future<Uint8List> build(CvData cvData) async {
    final doc = pw.Document();
    final info = cvData.personalInfo;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (context) => [
          _header(info),
          pw.Padding(
            padding: const pw.EdgeInsets.fromLTRB(_margin, 20, _margin, 40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (info.summary.isNotEmpty) ...[
                  _sectionTitle('PROFIL'),
                  pw.Text(
                    info.summary,
                    style: const pw.TextStyle(fontSize: 11, color: _body),
                  ),
                  pw.SizedBox(height: 16),
                ],
                if (cvData.experiences.isNotEmpty) ...[
                  _sectionTitle('EXPÉRIENCES'),
                  for (final exp in cvData.experiences) _experience(exp),
                ],
                if (cvData.educations.isNotEmpty) ...[
                  _sectionTitle('FORMATION'),
                  for (final edu in cvData.educations) _education(edu),
                  pw.SizedBox(height: 6),
                ],
                if (cvData.skills.isNotEmpty) ...[
                  _sectionTitle('COMPÉTENCES'),
                  _skills(cvData.skills),
                  pw.SizedBox(height: 6),
                ],
                if (cvData.languages.isNotEmpty) ...[
                  _sectionTitle('LANGUES'),
                  pw.Text(
                    cvData.languages
                        .map((l) => '${l.name} — ${l.level}')
                        .join('   ·   '),
                    style: const pw.TextStyle(fontSize: 11, color: _body),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  // ── Blocs de mise en page ──────────────────────────────────────────────

  static pw.Widget _header(PersonalInfo info) {
    final contacts = [
      if (info.email.isNotEmpty) info.email,
      if (info.phone.isNotEmpty) info.phone,
      if (info.city.isNotEmpty) info.city,
    ].join('  ·  ');

    return pw.Container(
      height: 120,
      width: double.infinity,
      color: _ink,
      padding: const pw.EdgeInsets.symmetric(horizontal: _margin),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            info.fullName.isEmpty ? 'Votre Nom' : info.fullName,
            style: const pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: _cream,
            ),
          ),
          if (info.jobTitle.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              info.jobTitle,
              style: const pw.TextStyle(fontSize: 14, color: _gold),
            ),
          ],
          if (contacts.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              contacts,
              style: const pw.TextStyle(fontSize: 10, color: _contact),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _gold,
            letterSpacing: 1.35,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Container(height: 0.8, color: _gold),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.Widget _experience(Experience exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  exp.position,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _strong,
                  ),
                ),
              ),
              pw.Text(
                exp.period,
                style: const pw.TextStyle(fontSize: 10, color: _date),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            exp.company,
            style: const pw.TextStyle(fontSize: 11, color: _sub),
          ),
          if (exp.description.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              exp.description,
              style: const pw.TextStyle(fontSize: 10, color: _sub),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _education(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Text(
                  edu.degree,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: _strong,
                  ),
                ),
              ),
              if (edu.years.isNotEmpty)
                pw.Text(
                  edu.years,
                  style: const pw.TextStyle(fontSize: 10, color: _date),
                ),
            ],
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            edu.schoolLine,
            style: const pw.TextStyle(fontSize: 11, color: _sub),
          ),
        ],
      ),
    );
  }

  /// Deux colonnes de barres de niveau — port du `chunked(2)` de Kotlin.
  static pw.Widget _skills(List<Skill> skills) {
    final rows = <pw.Widget>[];

    for (var i = 0; i < skills.length; i += 2) {
      final pair = skills.sublist(i, (i + 2).clamp(0, skills.length));
      rows.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 10),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final skill in pair) ...[
                pw.Expanded(child: _skillBar(skill)),
                pw.SizedBox(width: 20),
              ],
              if (pair.length == 1) pw.Expanded(child: pw.SizedBox()),
            ],
          ),
        ),
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: rows,
    );
  }

  /// Part remplie de la barre, exprimée en centièmes — `flex` n'accepte que
  /// des entiers. Bornée à [1, 100] pour qu'un niveau nul reste visible.
  ///
  /// Exposée pour les tests : c'est le seul calcul de la mise en page PDF qui
  /// se vérifie sans inspecter le document produit.
  @visibleForTesting
  static int filledFlexFor(SkillLevel level) => _filledFlex(level.value);

  static int _filledFlex(double level) => (level * 100).round().clamp(1, 100);

  static pw.Widget _skillBar(Skill skill) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                skill.name,
                style: const pw.TextStyle(fontSize: 11, color: _body),
              ),
            ),
            pw.Text(
              skill.level.label,
              style: const pw.TextStyle(fontSize: 9, color: _date),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        // Le package `pdf` n'a pas de FractionallySizedBox : on répartit la
        // barre en deux `Expanded` pondérés (niveau / reste) plutôt que de
        // superposer un remplissage sur un fond.
        pw.SizedBox(
          height: 5,
          child: pw.Row(
            children: [
              pw.Expanded(
                flex: _filledFlex(skill.level.value),
                child: pw.Container(color: _gold),
              ),
              if (_filledFlex(skill.level.value) < 100)
                pw.Expanded(
                  flex: 100 - _filledFlex(skill.level.value),
                  child: pw.Container(color: _barBg),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
