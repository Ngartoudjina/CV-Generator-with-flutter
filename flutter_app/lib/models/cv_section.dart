import 'cv_data.dart';

/// Les six sections d'un CV, dans l'ordre où l'éditeur les numérote —
/// `maquettes/05_editeur.jpg` affiche « 4 SUR 6 COMPLÈTES ».
///
/// Ce découpage n'existait pas dans le portage, qui avait quatre sections en
/// accordéon sans notion d'avancement. La maquette en fait le squelette de
/// l'écran : chaque section porte un numéro, un statut, et un décompte.
enum CvSection {
  profil('Profil'),
  experience('Expérience'),
  competences('Compétences'),
  formation('Formation'),
  langues('Langues'),
  contact('Contact');

  const CvSection(this.label);

  final String label;

  /// Numéro affiché — « 01 », « 02 »…
  String get number => '${index + 1}'.padLeft(2, '0');

  /// Une section est complète dès qu'elle porte une information exploitable.
  /// Le seuil est volontairement bas : l'objectif est de signaler ce qui
  /// manque, pas de juger la qualité — c'est le rôle du score ATS.
  bool isComplete(CvData d) => switch (this) {
        CvSection.profil => d.personalInfo.fullName.trim().isNotEmpty &&
            d.personalInfo.jobTitle.trim().isNotEmpty,
        CvSection.experience => d.experiences.any(
            (e) => e.position.trim().isNotEmpty || e.company.trim().isNotEmpty,
          ),
        CvSection.competences => d.skills.isNotEmpty,
        CvSection.formation => d.educations.any(
            (e) => e.degree.trim().isNotEmpty || e.school.trim().isNotEmpty,
          ),
        CvSection.langues => d.languages.isNotEmpty,
        CvSection.contact => d.personalInfo.email.trim().isNotEmpty,
      };

  /// Décompte affiché à droite quand la section est ouverte — « 3 POSTES ».
  String? countLabel(CvData d) => switch (this) {
        CvSection.experience when d.experiences.isNotEmpty =>
          '${d.experiences.length} POSTE'
              '${d.experiences.length > 1 ? "S" : ""}',
        CvSection.competences when d.skills.isNotEmpty =>
          '${d.skills.length} COMPÉTENCE'
              '${d.skills.length > 1 ? "S" : ""}',
        CvSection.formation when d.educations.isNotEmpty =>
          '${d.educations.length} DIPLÔME'
              '${d.educations.length > 1 ? "S" : ""}',
        CvSection.langues when d.languages.isNotEmpty =>
          '${d.languages.length} LANGUE'
              '${d.languages.length > 1 ? "S" : ""}',
        _ => null,
      };

  static int completedCount(CvData d) =>
      CvSection.values.where((s) => s.isComplete(d)).length;
}
