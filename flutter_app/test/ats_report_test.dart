import 'package:cvgenerator/models/ats_report.dart';
import 'package:cvgenerator/models/cv_data.dart';
import 'package:cvgenerator/state/cv_library.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le contrôle ATS est une simulation, pas un score inventé : chaque ligne se
/// calcule depuis le document. Ces tests verrouillent surtout ce qui distingue
/// une mesure honnete d'un chiffre decoratif.
void main() {
  AtsCheck checkNamed(AtsReport r, String label) =>
      r.checks.firstWhere((c) => c.label == label);

  group('Contrôle ATS', () {
    test('un CV vide echoue sur la forme, pas sur les mots-cles', () {
      final r = AtsReport.of(const CvData());

      expect(
          checkNamed(r, 'Coordonnées détectables').status, AtsStatus.warning);
      expect(checkNamed(r, 'Dates renseignées').status, AtsStatus.warning);

      // La structure reste bonne : c'est nous qui produisons le PDF.
      expect(checkNamed(r, 'Structure lisible par les robots').status,
          AtsStatus.ok);
    });

    test('le CV d\'exemple obtient une note elevee', () {
      final r = AtsReport.of(CvLibrary().current!.data);
      expect(r.score, greaterThanOrEqualTo(70));
      expect(r.okCount, greaterThanOrEqualTo(4));
    });

    test('sans offre, les mots-cles sont indisponibles et non echoues', () {
      final r = AtsReport.of(CvLibrary().current!.data);
      final kw = checkNamed(r, 'Mots-clés du poste couverts');

      expect(kw.status, AtsStatus.unavailable);
      expect(kw.detail, 'À DÉFINIR');
    });

    test('une verification indisponible ne penalise pas la note', () {
      final data = CvLibrary().current!.data;

      final sans = AtsReport.of(data);
      // Une offre dont aucun terme n'apparait : la ligne devient un echec.
      final avec = AtsReport.of(
        data,
        jobOffer: 'menuiserie charpente ebenisterie toiture zinguerie',
      );

      expect(
        avec.score,
        lessThan(sans.score),
        reason: 'une offre non couverte doit faire baisser la note, '
            'alors que son absence ne la baissait pas',
      );
    });

    test('une offre couverte est detectee', () {
      final r = AtsReport.of(
        CvLibrary().current!.data,
        jobOffer: 'Kotlin Android Firebase Jetpack Compose applications '
            'mobiles performances',
      );
      final kw = checkNamed(r, 'Mots-clés du poste couverts');

      expect(kw.status, AtsStatus.ok);
    });

    test('les resultats chiffres reperent un nombre dans la description', () {
      CvData withDescription(String d) => CvData(
            experiences: [Experience(position: 'Dev', description: d)],
          );

      expect(
        checkNamed(AtsReport.of(withDescription('Forte croissance du CA.')),
                'Résultats chiffrés')
            .status,
        AtsStatus.warning,
      );
      expect(
        checkNamed(AtsReport.of(withDescription('CA porte de 18 a 32 %.')),
                'Résultats chiffrés')
            .status,
        AtsStatus.ok,
      );
    });
  });
}
