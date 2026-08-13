import 'package:cvgenerator/app.dart';
import 'package:cvgenerator/models/cv_data.dart';
import 'package:cvgenerator/state/cv_model.dart';
import 'package:flutter_test/flutter_test.dart';
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
