import 'dart:convert';

import 'package:cvgenerator/models/cv_data.dart';
import 'package:cvgenerator/pdf/pdf_generator.dart';
import 'package:cvgenerator/state/cv_library.dart';
import 'package:flutter_test/flutter_test.dart';

/// `PdfGenerator` est la seule partie réellement réécrite du portage (canvas
/// Android → widgets du package `pdf`), et la plus silencieuse en cas de
/// problème : un PDF mal formé s'ouvre sur une page blanche sans erreur.
///
/// Ces tests vérifient la structure du document produit, pas son apparence.
void main() {
  /// Un PDF valide commence par `%PDF-` et se termine par `%%EOF`.
  void expectValidPdf(List<int> bytes) {
    expect(bytes.length, greaterThan(1000), reason: 'document non vide');
    expect(
      latin1.decode(bytes.take(5).toList()),
      '%PDF-',
      reason: 'en-tête PDF',
    );
    expect(
      latin1.decode(bytes.skip(bytes.length - 8).toList()),
      contains('%%EOF'),
      reason: 'fin de fichier PDF',
    );
  }

  /// Nombre de pages, lu dans l'entrée `/Count` de l'arbre des pages — c'est
  /// le compteur que porte le format lui-même. Compter les occurrences de
  /// `/Type/Page` serait fragile : le package écrit sans espace après `/Type`,
  /// et `/Type/Pages` du nœud racine viendrait fausser le total.
  int pageCount(List<int> bytes) {
    final match = RegExp(r'/Count\s+(\d+)')
        .firstMatch(latin1.decode(bytes, allowInvalid: true));
    expect(match, isNotNull, reason: 'arbre des pages introuvable');
    return int.parse(match!.group(1)!);
  }

  group('PdfGenerator', () {
    test('produit un PDF valide à partir d\'un CV complet', () async {
      final bytes = await PdfGenerator.build(CvLibrary().current!.data);
      expectValidPdf(bytes);
    });

    test('un CV vide produit quand même un PDF valide', () async {
      // Cas atteignable : « Créer un nouveau CV » puis export immédiat.
      final bytes = await PdfGenerator.build(const CvData());
      expectValidPdf(bytes);
    });

    test('les accents et le tiret cadratin ne cassent pas l\'encodage',
        () async {
      // La police Helvetica par défaut du package `pdf` utilise WinAnsi.
      // Les caractères hors de ce jeu lèvent une exception à la génération.
      final bytes = await PdfGenerator.build(
        CvData(
          personalInfo: const PersonalInfo(
            fullName: 'Amélie Dupont-Sébastien',
            jobTitle: 'Chargée de projet · Marketing',
            email: 'a@example.com',
            city: 'Nîmes, France',
            summary: 'Élaboration de stratégies — résultats mesurés à 32 %.',
          ),
          experiences: [
            Experience(
              position: 'Cheffe d\'équipe',
              company: 'Société Générale',
              startDate: '2021',
              isCurrent: true,
              description: 'Pilotage d\'une équipe de six personnes.',
            ),
          ],
        ),
      );
      expectValidPdf(bytes);
    });

    test('le contenu long déborde sur plusieurs pages', () async {
      // La version Kotlin dessinait sur une page unique de 842 points et
      // tronquait silencieusement le reste. MultiPage doit paginer.
      final bytes = await PdfGenerator.build(
        CvData(
          personalInfo: const PersonalInfo(
            fullName: 'Fatou Sow',
            jobTitle: 'Ingénieure',
            email: 'f@example.com',
          ),
          experiences: [
            for (var i = 0; i < 25; i++)
              Experience(
                position: 'Poste numéro $i',
                company: 'Entreprise $i',
                startDate: '20${10 + (i % 15)}',
                endDate: '20${11 + (i % 15)}',
                description: 'Description détaillée du poste $i, '
                    'suffisamment longue pour occuper plusieurs lignes '
                    'et forcer la pagination du document.',
              ),
          ],
        ),
      );

      expectValidPdf(bytes);
      expect(
        pageCount(bytes),
        greaterThan(1),
        reason: 'le contenu doit être paginé, pas tronqué',
      );
    });

    test('un CV court tient sur une seule page', () async {
      final bytes = await PdfGenerator.build(
        const CvData(
          personalInfo: PersonalInfo(
            fullName: 'Fatou Sow',
            jobTitle: 'Ingénieure',
            email: 'f@example.com',
          ),
        ),
      );
      expect(pageCount(bytes), 1);
    });

    test('les niveaux de compétence se traduisent en largeurs de barre', () {
      // Le package `pdf` n'a pas de FractionallySizedBox : la barre est
      // répartie en deux Expanded pondérés, d'où ce calcul en centièmes.
      expect(PdfGenerator.filledFlexFor(SkillLevel.beginner), 25);
      expect(PdfGenerator.filledFlexFor(SkillLevel.intermediate), 50);
      expect(PdfGenerator.filledFlexFor(SkillLevel.advanced), 75);
      expect(PdfGenerator.filledFlexFor(SkillLevel.expert), 100);
    });
  });

  group('Nom du fichier exporté', () {
    test('les espaces deviennent des soulignés', () {
      final name = PdfGenerator.fileName(
        const CvData(personalInfo: PersonalInfo(fullName: 'Amina Diallo')),
      );
      expect(name, 'CV_Amina_Diallo.pdf');
    });

    test('un nom vide retombe sur un libellé neutre', () {
      expect(PdfGenerator.fileName(const CvData()), 'CV_Sans_nom.pdf');
    });
  });
}
