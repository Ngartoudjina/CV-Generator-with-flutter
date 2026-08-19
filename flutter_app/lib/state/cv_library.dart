import 'package:flutter/foundation.dart';

import '../models/cv_data.dart';
import '../models/cv_document.dart';

/// Collection des CV enregistrés — ce que liste le tableau de bord.
///
/// `DashboardScreen.kt` affichait une constante `sampleCvs` : trois entrées
/// figées, non modifiables, avec des scores inventés. Cette classe leur
/// substitue de vraies données, éditables et cohérentes avec ce que produit
/// l'éditeur.
///
/// [CvModel] reste la copie de travail (le CV en cours d'édition) ;
/// [CvLibrary] est le magasin. Ouvrir un document charge son contenu dans
/// [CvModel], et chaque modification est répercutée ici par [updateCurrent].
class CvLibrary extends ChangeNotifier {
  CvLibrary({List<CvDocument>? documents})
      : _documents = documents ?? [_sampleDocument()] {
    _currentId = _documents.isEmpty ? null : _documents.first.id;
  }

  List<CvDocument> _documents;
  String? _currentId;

  List<CvDocument> get documents => List.unmodifiable(_documents);
  String? get currentId => _currentId;

  CvDocument? get current {
    if (_currentId == null) return null;
    for (final d in _documents) {
      if (d.id == _currentId) return d;
    }
    return null;
  }

  /// Documents du plus récemment modifié au plus ancien.
  List<CvDocument> get sortedByDate {
    final copy = [..._documents]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy;
  }

  /// Crée un CV vierge et le désigne comme courant. Renvoie son identifiant.
  String createNew({String title = defaultTitle}) {
    final doc = CvDocument(
      title: title,
      data: const CvData(),
      updatedAt: DateTime.now(),
    );
    _documents = [..._documents, doc];
    _currentId = doc.id;
    notifyListeners();
    return doc.id;
  }

  /// Désigne un document comme courant. Sans effet si l'identifiant est
  /// inconnu — le tableau de bord peut référencer un CV supprimé ailleurs.
  void open(String id) {
    if (!_documents.any((d) => d.id == id)) return;
    _currentId = id;
    notifyListeners();
  }

  /// Titre donné à un CV tant que l'utilisateur n'en a pas choisi un.
  static const String defaultTitle = 'Nouveau CV';

  /// Enregistre le contenu de la copie de travail dans le document courant.
  /// Sans effet si le contenu est inchangé, pour éviter une cascade de
  /// notifications à chaque frappe.
  void updateCurrent(CvData data) {
    final doc = current;
    if (doc == null || identical(doc.data, data)) return;

    _documents = [
      for (final d in _documents)
        if (d.id == doc.id)
          d.copyWith(
            data: data,
            title: _autoTitle(d.title, data),
            updatedAt: DateTime.now(),
          )
        else
          d,
    ];
    notifyListeners();
  }

  /// Sans cela, tous les CV créés depuis le tableau de bord resteraient
  /// « Nouveau CV » et seraient indiscernables dans la liste.
  ///
  /// La règle ne s'applique que tant que le titre est celui par défaut : dès
  /// que l'utilisateur en choisit un via [rename], il n'est plus touché.
  String _autoTitle(String currentTitle, CvData data) {
    if (currentTitle != defaultTitle) return currentTitle;
    final job = data.personalInfo.jobTitle.trim();
    return job.isEmpty ? currentTitle : 'CV $job';
  }

  /// Change la police du document — onglet Modèles.
  void setFont(String id, String fontFamily) {
    _documents = [
      for (final d in _documents)
        if (d.id == id)
          d.copyWith(fontFamily: fontFamily, updatedAt: DateTime.now())
        else
          d,
    ];
    notifyListeners();
  }

  /// Enregistre l'offre visée, qui débloque la correspondance de mots-clés.
  void setJobOffer(String id, String offer) {
    _documents = [
      for (final d in _documents)
        if (d.id == id)
          d.copyWith(jobOffer: offer, updatedAt: DateTime.now())
        else
          d,
    ];
    notifyListeners();
  }

  void rename(String id, String title) {
    _documents = [
      for (final d in _documents)
        if (d.id == id)
          d.copyWith(title: title, updatedAt: DateTime.now())
        else
          d,
    ];
    notifyListeners();
  }

  void remove(String id) {
    _documents = _documents.where((d) => d.id != id).toList();
    if (_currentId == id) {
      _currentId = _documents.isEmpty ? null : _documents.first.id;
    }
    notifyListeners();
  }

  /// Exemple présent au premier lancement, pour que le tableau de bord ne
  /// soit pas vide. C'est un vrai document : modifiable et supprimable, à la
  /// différence des `sampleCvs` figés de la version Kotlin.
  static CvDocument _sampleDocument() {
    return CvDocument(
      title: 'CV Senior Dev',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      data: CvData(
        personalInfo: const PersonalInfo(
          fullName: 'Amina Diallo',
          jobTitle: 'Développeuse Full-Stack',
          email: 'amina@example.com',
          city: 'Paris, France',
          summary: "Développeuse passionnée avec 5 ans d'expérience dans la "
              "création d'applications mobiles et web à fort impact.",
        ),
        experiences: [
          Experience(
            position: 'Développeuse Full-Stack',
            company: 'TechCorp SAS',
            startDate: '2021',
            isCurrent: true,
            description:
                "Développement d'applications mobiles Android avec Kotlin et "
                'Jetpack Compose. Amélioration des performances de 40 %.',
          ),
        ],
        educations: [
          Education(
            degree: 'Master Informatique',
            school: 'Université Paris-Saclay',
            field: 'Génie logiciel',
            endYear: '2019',
          ),
        ],
        skills: [
          Skill(name: 'Kotlin'),
          Skill(name: 'Android', level: SkillLevel.expert),
          Skill(name: 'Jetpack Compose'),
          Skill(name: 'Firebase', level: SkillLevel.advanced),
        ],
        languages: [
          Language(name: 'Français', level: 'Natif'),
          Language(name: 'Anglais', level: 'Courant'),
        ],
      ),
    );
  }
}
