import 'package:cvgenerator/app.dart';
import 'package:cvgenerator/models/cv_data.dart';
import 'package:cvgenerator/models/cv_document.dart';
import 'package:cvgenerator/screens/cv_wizard_screen.dart';
import 'package:cvgenerator/screens/dashboard_screen.dart';
import 'package:cvgenerator/screens/editor_screen.dart';
import 'package:cvgenerator/screens/onboarding/onboarding_flow.dart';
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

      // L'accroche de la maquette tient sur une ligne, suivie du mot
      // qui change en rouge.
      expect(find.text('Le CV qui vous fait'), findsOneWidget);
    });

    testWidgets('onboardé mais non connecté → Auth', (tester) async {
      SharedPreferences.setMockInitialValues({kOnboardingDone: true});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(CvGeneratorApp(prefs: prefs));
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.textContaining('Reprendre où vous'), findsOneWidget);
    });

    testWidgets('connecté → Dashboard', (tester) async {
      SharedPreferences.setMockInitialValues({
        kOnboardingDone: true,
        kLoggedIn: true,
      });
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(CvGeneratorApp(prefs: prefs));
      await tester.pump(const Duration(milliseconds: 900));

      // « Mes CV » ne montre plus le nom du porteur en en-tête : la maquette
      // met le titre de l'écran, et l'identité vit dans l'onglet Profil.
      expect(find.text('Mes CV'), findsOneWidget);
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

      // L'éditeur ouvre « Expérience » par défaut, comme la maquette :
      // « Nom complet » vit dans « Profil », qu'il faut déplier d'abord.
      await tester.tap(find.text('Profil'));
      await tester.pump(const Duration(milliseconds: 400));

      // Une frappe dans « Nom complet » doit se retrouver dans le modèle —
      // c'est exactement ce que la version Compose perdait.
      await tester.enterText(
        find.widgetWithText(TextField, 'Amina Diallo'),
        'Fatou Sow',
      );
      await tester.pump();

      expect(model.cvData.personalInfo.fullName, 'Fatou Sow');
    });

    testWidgets('toutes les expériences sont éditables, pas seulement la 1re',
        (tester) async {
      // Un CV créé dans l'assistant avec plusieurs expériences n'en montrait
      // qu'une dans l'éditeur : les autres restaient invisibles ici tout en
      // figurant dans l'aperçu et le PDF.
      final library = CvLibrary();
      final model = CvModel()
        ..load(
          CvData(
            personalInfo: const PersonalInfo(fullName: 'Fatou Sow'),
            experiences: [
              Experience(position: 'Developpeuse', company: 'Alpha'),
              Experience(position: 'Lead', company: 'Beta'),
            ],
          ),
        );

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

      // « Expérience » est dépliée d'entrée : les deux postes doivent avoir
      // leur propre champ. Le portage n'en montrait qu'un.
      expect(find.widgetWithText(TextField, 'Alpha'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Beta'), findsOneWidget);

      // Modifier le second ne doit pas toucher le premier.
      await tester.enterText(find.widgetWithText(TextField, 'Beta'), 'Delta');
      await tester.pump();

      expect(model.cvData.experiences[1].company, 'Delta');
      expect(model.cvData.experiences[0].company, 'Alpha');
      expect(model.cvData.experiences, hasLength(2));
    });
  });

  group('Onboarding', () {
    Widget flow(CvModel model, {VoidCallback? onComplete}) =>
        ChangeNotifierProvider<CvModel>.value(
          value: model,
          child: MaterialApp(
            home: OnboardingFlow(onComplete: onComplete ?? () {}),
          ),
        );

    testWidgets('chaque étape écrit dans le CV, qui existe à la fin',
        (tester) async {
      // Le portage enchaînait six écrans de présentation qui ne produisaient
      // rien : on arrivait ensuite devant un CV vide. Ici l'onboarding EST la
      // création.
      final model = CvModel();
      var done = false;

      await tester.pumpWidget(flow(model, onComplete: () => done = true));
      await tester.pump();

      expect(find.text('ÉTAPE 01 · IDENTITÉ'), findsOneWidget);
      expect(find.textContaining('0 CHAMP SUR 8'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Fatou Sow');
      await tester.pump();
      expect(model.cvData.personalInfo.fullName, 'Fatou Sow');
      // Accord au singulier : « 1 CHAMP », pas « 1 CHAMPS ».
      expect(find.textContaining('1 CHAMP SUR 8'), findsOneWidget);

      await tester.tap(find.text('Continuer'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('ÉTAPE 02 · POSTE VISÉ'), findsOneWidget);

      // Une suggestion remplit le champ sans passer par le clavier.
      await tester.tap(find.text('UX Designer'));
      await tester.pump();
      expect(model.cvData.personalInfo.jobTitle, 'UX Designer');

      // On saute jusqu'au bout : « Passer cette étape » avance sans exiger
      // de saisie, comme la maquette le prévoit. Depuis l'étape 02, il faut
      // trois appuis pour atteindre la dernière, un quatrième pour terminer.
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.text('Passer cette étape'));
        await tester.pump(const Duration(milliseconds: 400));
      }

      expect(done, isTrue, reason: 'la dernière étape termine le parcours');
      expect(model.cvData.personalInfo.fullName, 'Fatou Sow');
    });

    testWidgets('le retour arrière conserve ce qui a été saisi',
        (tester) async {
      final model = CvModel();
      await tester.pumpWidget(flow(model));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Fatou Sow');
      await tester.pump();

      await tester.tap(find.text('Continuer'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 400));

      // Le champ est réamorcé depuis le modèle, pas vidé.
      expect(find.text('Fatou Sow'), findsWidgets);
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

    test('le titre par défaut suit le poste, un titre choisi ne bouge plus',
        () {
      final library = CvLibrary()..createNew();
      expect(library.current!.title, CvLibrary.defaultTitle);

      // Tant que le titre est celui par défaut, il suit le poste saisi —
      // sinon tous les CV créés resteraient indiscernables dans la liste.
      library.updateCurrent(
        const CvData(personalInfo: PersonalInfo(jobTitle: 'Product Designer')),
      );
      expect(library.current!.title, 'CV Product Designer');

      // Une fois renommé explicitement, il est laissé tranquille.
      library.rename(library.currentId!, 'CV Alternance');
      library.updateCurrent(
        const CvData(personalInfo: PersonalInfo(jobTitle: 'Autre chose')),
      );
      expect(library.current!.title, 'CV Alternance');
    });
  });

  group('Assistant de création', () {
    Widget wizard(CvModel model) => MultiProvider(
          providers: [
            ChangeNotifierProvider<CvLibrary>(create: (_) => CvLibrary()),
            ChangeNotifierProvider<CvModel>.value(value: model),
          ],
          child: MaterialApp(home: CvWizardScreen(onBack: () {})),
        );

    testWidgets('l\'étape Identité bloque tant qu\'elle est incomplète',
        (tester) async {
      final model = CvModel();
      await tester.pumpWidget(wizard(model));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Étape 1 / 5'), findsOneWidget);

      // « Suivant » est désactivé : nom, titre et email sont vides.
      final next = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Suivant'),
      );
      expect(next.onPressed, isNull);

      // Cliquer une pastille plus loin est refusé, avec une explication.
      await tester.tap(find.text('Compétences'));
      await tester.pump(); // déclenche le SnackBar
      await tester.pump(const Duration(milliseconds: 400)); // le fait entrer

      expect(find.textContaining('pour continuer'), findsOneWidget);
      expect(model.currentStep, 0);
    });

    testWidgets('une fois l\'identité remplie, la navigation se débloque',
        (tester) async {
      final model = CvModel()
        ..updatePersonalInfo(
          const PersonalInfo(
            fullName: 'Fatou Sow',
            jobTitle: 'Designer',
            email: 'f@example.com',
          ),
        );

      await tester.pumpWidget(wizard(model));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.widgetWithText(FilledButton, 'Suivant'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(model.currentStep, 1);
      expect(find.text('Étape 2 / 5'), findsOneWidget);
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

      await tester.tap(find.text('PROFIL'));
      await tester.pump(const Duration(milliseconds: 400));

      // L'identité vient du CV le plus récent, faute de compte utilisateur.
      expect(find.text('amina@example.com'), findsOneWidget);

      // L'écran est plus long que la surface de test, et sa liste est
      // paresseuse : la déconnexion, en bas, demande un défilement.
      await tester.scrollUntilVisible(
        find.text('Se déconnecter'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Se déconnecter'));
      await tester.pump();
      expect(signedOut, isTrue);
    });
    testWidgets('le profil renvoie au choix de police', (tester) async {
      // La ligne « Police du document » de la maquette 08 n'ouvre pas un
      // écran de plus : elle mène là où le choix se fait déjà.
      await tester.pumpWidget(dashboard());
      await tester.pump(const Duration(milliseconds: 900));

      await tester.tap(find.text('PROFIL'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(find.text('Police du document'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('POLICE DU DOCUMENT'), findsOneWidget);
    });

    testWidgets('une bibliothèque vide propose de créer un CV', (tester) async {
      var created = false;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<CvModel>(create: (_) => CvModel()),
            ChangeNotifierProvider<CvLibrary>(
              create: (_) => CvLibrary(documents: []),
            ),
          ],
          child: MaterialApp(
            home: DashboardScreen(
              onOpenEditor: (_) {},
              onCreateNew: () => created = true,
              onSignOut: () {},
              onReplayOnboarding: () {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text("Aucun CV pour l'instant"), findsOneWidget);
      await tester.tap(find.text('Créer mon premier CV'));
      expect(created, isTrue);
    });

    testWidgets("L'onglet Modeles propose et applique une police",
        (tester) async {
      // L'onglet existait dans la maquette mais restait vide. Il porte
      // desormais le choix de police du document.
      await tester.pumpWidget(dashboard());
      await tester.pump(const Duration(milliseconds: 900));

      await tester.tap(find.text('MODÈLES'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('POLICE DU DOCUMENT'), findsOneWidget);

      // La première proposition est visible ; les suivantes demandent un
      // défilement, la liste étant paresseuse.
      expect(find.text('Inter'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Lora'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Lora'), findsOneWidget);

      // Et il est dit clairement que cela ne change pas le score ATS.
      await tester.scrollUntilVisible(
        find.textContaining("n'influence pas le score ATS"),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining("n'influence pas le score ATS"),
        findsOneWidget,
      );
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
