import 'package:cvgenerator/app.dart';
import 'package:cvgenerator/models/cv_data.dart';
import 'package:cvgenerator/models/cv_document.dart';
import 'package:cvgenerator/screens/dashboard_screen.dart';
import 'package:cvgenerator/screens/editor_screen.dart';
import 'package:cvgenerator/state/cv_library.dart';
import 'package:cvgenerator/state/cv_model.dart';
import 'package:cvgenerator/state/cv_storage.dart';
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
      final library = CvLibrary();
      final model = CvModel()..load(library.current!.data);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CvLibrary>.value(value: library),
            ChangeNotifierProvider<CvModel>.value(value: model),
          ],
          child: MaterialApp(
            home: EditorScreen(onBack: () {}, onExport: () {}),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));

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

  group('CvLibrary', () {
    test('démarre avec un exemple modifiable et supprimable', () {
      final library = CvLibrary();
      expect(library.documents, hasLength(1));
      expect(library.current, isNotNull);

      library.remove(library.current!.id);
      expect(library.documents, isEmpty);
      expect(library.current, isNull);
    });

    test('createNew ajoute un document vierge et le rend courant', () {
      final library = CvLibrary();
      final id = library.createNew();

      expect(library.documents, hasLength(2));
      expect(library.currentId, id);
      expect(library.current!.data.personalInfo.fullName, isEmpty);
      expect(library.current!.isDraft, isTrue, reason: 'vide donc brouillon');
    });

    test('updateCurrent enregistre dans le document courant seulement', () {
      final library = CvLibrary();
      final firstId = library.documents.first.id;
      library.createNew();

      library.updateCurrent(
        const CvData(personalInfo: PersonalInfo(fullName: 'Fatou Sow')),
      );

      final updated = library.documents.firstWhere((d) => d.id != firstId);
      final untouched = library.documents.firstWhere((d) => d.id == firstId);
      expect(updated.data.personalInfo.fullName, 'Fatou Sow');
      expect(untouched.data.personalInfo.fullName, 'Amina Diallo');
    });

    test('open ignore un identifiant inconnu', () {
      final library = CvLibrary();
      final before = library.currentId;
      library.open('identifiant-inexistant');
      expect(library.currentId, before);
    });
  });

  group('Onglets du tableau de bord', () {
    Widget dashboard({VoidCallback? onSignOut}) => MultiProvider(
          providers: [
            ChangeNotifierProvider<CvLibrary>(create: (_) => CvLibrary()),
          ],
          child: MaterialApp(
            home: DashboardScreen(
              onOpenEditor: (_) {},
              onCreateNew: () {},
              onSignOut: onSignOut ?? () {},
              onReplayOnboarding: () {},
            ),
          ),
        );

    testWidgets('l\'onglet Profil affiche l\'identité et déconnecte',
        (tester) async {
      var signedOut = false;
      await tester.pumpWidget(dashboard(onSignOut: () => signedOut = true));
      await tester.pump(const Duration(milliseconds: 900));

      await tester.tap(find.text('Profil'));
      await tester.pump(const Duration(milliseconds: 400));

      // L'identité vient du CV le plus récent, faute de compte utilisateur.
      expect(find.text('amina@example.com'), findsOneWidget);

      await tester.tap(find.text('Se déconnecter'));
      await tester.pump();
      expect(signedOut, isTrue);
    });

    testWidgets('les onglets sans implémentation le disent', (tester) async {
      await tester.pumpWidget(dashboard());
      await tester.pump(const Duration(milliseconds: 900));

      await tester.tap(find.text('Modèles'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('pas encore implémentée'), findsOneWidget);

      await tester.tap(find.text('IA'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('pas branchée'), findsOneWidget);
    });
  });

  group('Persistance', () {
    Future<CvStorage> newStorage() async {
      SharedPreferences.setMockInitialValues({});
      return CvStorage(await SharedPreferences.getInstance());
    }

    test('un aller-retour disque conserve le contenu', () async {
      final storage = await newStorage();
      final source = CvLibrary();
      source.updateCurrent(
        source.current!.data.copyWith(
          personalInfo: const PersonalInfo(
            fullName: 'Fatou Sow',
            jobTitle: 'Designer',
            email: 'f@example.com',
          ),
        ),
      );

      await storage.save(source.documents);
      final restored = CvLibrary(documents: storage.load());

      expect(restored.documents, hasLength(1));
      final doc = restored.documents.first;
      expect(doc.data.personalInfo.fullName, 'Fatou Sow');
      expect(doc.data.skills.map((s) => s.name),
          source.current!.data.skills.map((s) => s.name));
      expect(doc.data.experiences.first.isCurrent, isTrue);
      expect(doc.data.skills.any((s) => s.level == SkillLevel.expert), isTrue);
      expect(doc.title, source.documents.first.title);
    });

    test('rien d\'enregistré → exemple ; liste vide → reste vide', () async {
      final storage = await newStorage();

      // Jamais enregistré : load() renvoie null, l'exemple apparaît.
      expect(storage.load(), isNull);
      expect(CvLibrary(documents: storage.load()).documents, hasLength(1));

      // Tout supprimé : la liste vide est respectée, l'exemple ne revient pas.
      await storage.save([]);
      expect(storage.load(), isEmpty);
      expect(CvLibrary(documents: storage.load()).documents, isEmpty);
    });

    test('un contenu illisible ne fait pas planter le démarrage', () async {
      SharedPreferences.setMockInitialValues({
        'cv_documents': '{ ceci n\'est pas du JSON',
      });
      final storage = CvStorage(await SharedPreferences.getInstance());

      expect(storage.load(), isEmpty);

      // Le contenu fautif est conservé plutôt que détruit en silence.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cv_documents_corrupt'), isNotNull);
    });
  });

  group('Score de complétude', () {
    test('un CV vide vaut 0, un CV complet dépasse le seuil de brouillon', () {
      final vide = CvDocument(
        title: 'Vide',
        data: const CvData(),
        updatedAt: DateTime.now(),
      );
      expect(vide.score, 0);
      expect(vide.isDraft, isTrue);

      final complet = CvLibrary().current!;
      expect(complet.score, greaterThanOrEqualTo(70));
      expect(complet.isDraft, isFalse);
    });

    test('le score progresse avec le contenu ajouté', () {
      CvDocument doc(CvData d) =>
          CvDocument(title: 't', data: d, updatedAt: DateTime.now());

      final identite = doc(
        const CvData(
          personalInfo: PersonalInfo(
            fullName: 'Fatou Sow',
            jobTitle: 'Designer',
            email: 'f@example.com',
          ),
        ),
      );
      final avecCompetences = doc(
        CvData(
          personalInfo: identite.data.personalInfo,
          skills: [Skill(name: 'Figma'), Skill(name: 'Sketch')],
        ),
      );

      expect(avecCompetences.score, greaterThan(identite.score));
      expect(identite.score, lessThan(70));
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
