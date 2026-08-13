import 'package:cvgenerator/app.dart';
import 'package:cvgenerator/models/cv_data.dart';
import 'package:cvgenerator/screens/editor_screen.dart';
import 'package:cvgenerator/state/cv_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remplace le test généré par `flutter create`, qui référençait un `MyApp`
/// inexistant. Couvre les deux invariants du portage les plus faciles à
/// casser : le choix de l'écran initial selon les préférences, et les
/// mutations immuables de `CvModel`.
void main() {
  group('Écran initial selon les préférences', () {
    testWidgets('première visite → Welcome', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(CvGeneratorApp(prefs: prefs));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('Le CV qui'), findsOneWidget);
    });

    testWidgets('onboardé mais non connecté → Auth', (tester) async {
      SharedPreferences.setMockInitialValues({kOnboardingDone: true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(CvGeneratorApp(prefs: prefs));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('Bon retour 👋'), findsOneWidget);
    });

    testWidgets('connecté → Dashboard', (tester) async {
      SharedPreferences.setMockInitialValues({
        kOnboardingDone: true,
        kLoggedIn: true,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(CvGeneratorApp(prefs: prefs));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('Amina Diallo'), findsOneWidget);
    });
  });

  group('EditorScreen ↔ CvModel', () {
    testWidgets('la saisie atteint le modèle, donc le PDF exporté',
        (tester) async {
      final model = CvModel();

      await tester.pumpWidget(
        ChangeNotifierProvider<CvModel>.value(
          value: model,
          child: MaterialApp(
            home: EditorScreen(onBack: () {}, onExport: () {}),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

      // L'écran amorce le modèle au lieu de garder son état pour lui.
      expect(model.cvData.personalInfo.fullName, isNotEmpty);
      expect(model.cvData.experiences, isNotEmpty);
      expect(model.cvData.skills, isNotEmpty);

      // Une frappe dans « Nom complet » doit se retrouver dans le modèle —
      // c'est exactement ce que la version Compose perdait.
      await tester.enterText(
        find.widgetWithText(TextField, 'Amina Diallo'),
        'Fatou Sow',
      );
      await tester.pump();

      expect(model.cvData.personalInfo.fullName, 'Fatou Sow');
    });
  });

  group('CvModel', () {
    test('ajout et suppression conservent l\'immuabilité', () {
      final model = CvModel();
      final before = model.cvData;

      final exp = Experience(company: 'TechCorp', position: 'Dev');
      model.addExperience(exp);

      expect(before.experiences, isEmpty, reason: 'état initial non muté');
      expect(model.cvData.experiences, hasLength(1));

      model.removeExperience(exp.id);
      expect(model.cvData.experiences, isEmpty);
    });

    test('updateExperience ne touche que la ligne ciblée', () {
      final model = CvModel();
      final a = Experience(company: 'A', position: 'Dev');
      final b = Experience(company: 'B', position: 'Lead');
      model
        ..addExperience(a)
        ..addExperience(b)
        ..updateExperience(b.copyWith(company: 'B2'));

      expect(model.cvData.experiences.first.company, 'A');
      expect(model.cvData.experiences.last.company, 'B2');
    });

    test('goToStep borne l\'index aux étapes existantes', () {
      final model = CvModel();

      model.goToStep(99);
      expect(model.currentStep, CvModel.totalSteps - 1);

      model.goToStep(-5);
      expect(model.currentStep, 0);

      model.previousStep();
      expect(model.currentStep, 0, reason: 'pas de débordement sous zéro');
    });

    test('period et years ne laissent pas de tiret orphelin', () {
      expect(
        Experience(startDate: '2021', endDate: '2023').period,
        '2021 — 2023',
      );
      expect(Experience(startDate: '2021', isCurrent: true).period,
          '2021 — Présent');
      expect(Experience(startDate: '2021').period, '2021');
      expect(Experience(endDate: '2023').period, '2023');
      expect(Experience().period, isEmpty);

      expect(
          Education(startYear: '2017', endYear: '2019').years, '2017 — 2019');
      expect(Education(endYear: '2019').years, '2019');
      expect(Education().years, isEmpty);
    });

    test('schoolLine n\'ajoute le séparateur que si la spécialité existe', () {
      expect(Education(school: 'Paris-Saclay').schoolLine, 'Paris-Saclay');
      expect(
        Education(school: 'Paris-Saclay', field: 'Informatique').schoolLine,
        'Paris-Saclay · Informatique',
      );
    });

    test('notifie ses écouteurs à chaque mutation', () {
      final model = CvModel();
      var notifications = 0;
      model.addListener(() => notifications++);

      model.updatePersonalInfo(const PersonalInfo(fullName: 'Amina'));
      model.addSkill(Skill(name: 'Dart'));

      expect(notifications, 2);
    });
  });
}
