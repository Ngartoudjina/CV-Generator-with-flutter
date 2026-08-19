import 'dart:math';

import 'cv_data.dart';

/// Un CV enregistré : son contenu, plus les métadonnées qu'affiche le tableau
/// de bord (titre, date de modification, score).
///
/// N'existe pas dans le projet Kotlin : `DashboardScreen.kt` affichait une
/// liste `sampleCvs` figée, avec des scores écrits en dur (92, 78, 85).
class CvDocument {
  CvDocument({
    String? id,
    required this.title,
    required this.data,
    required this.updatedAt,
    this.targetRole = '',
    this.templateName = 'Ravel',
    this.version = 1,
  }) : id = id ?? _newId();

  final String id;
  final String title;
  final CvData data;
  final DateTime updatedAt;

  /// Poste visé — c'est par lui que la maquette `04_mes-cv.jpg` regroupe la
  /// liste (« PRODUCT DESIGNER », « DESIGN LEAD »). Un même parcours donne
  /// plusieurs CV, un par poste ciblé : c'est le cœur de l'organisation
  /// proposée, et la notion n'existait pas dans le portage.
  final String targetRole;

  /// Modèle de mise en page — « Ravel », « Ligne ». Affiché dans la
  /// métadonnée de chaque ligne.
  final String templateName;

  /// Numéro de version, affiché dans l'éditeur (« OVALIS · V3 »).
  final int version;

  CvDocument copyWith({
    String? title,
    CvData? data,
    DateTime? updatedAt,
    String? targetRole,
    String? templateName,
    int? version,
  }) {
    return CvDocument(
      id: id,
      title: title ?? this.title,
      data: data ?? this.data,
      updatedAt: updatedAt ?? this.updatedAt,
      targetRole: targetRole ?? this.targetRole,
      templateName: templateName ?? this.templateName,
      version: version ?? this.version,
    );
  }

  /// Groupe d'appartenance dans « Mes CV ».
  ///
  /// À défaut de poste visé explicite, on retombe sur le titre professionnel
  /// saisi ; un document sans ni l'un ni l'autre part dans les brouillons.
  String get group {
    final explicit = targetRole.trim();
    if (explicit.isNotEmpty) return explicit.toUpperCase();
    final job = data.personalInfo.jobTitle.trim();
    if (job.isNotEmpty && !isDraft) return job.toUpperCase();
    return 'BROUILLON';
  }

  /// Score de complétude sur 100.
  ///
  /// **Ce n'est pas une analyse ATS.** C'est une heuristique de complétude,
  /// volontairement transparente, qui remplace les valeurs inventées de la
  /// maquette. Une vraie analyse (mots-clés du poste visé, verbes d'action,
  /// résultats chiffrés) demanderait un service d'analyse — c'est le point
  /// d'accroche prévu pour l'IA promise par l'onboarding.
  int get score {
    final info = data.personalInfo;
    var total = 0;

    // Identité — 25
    var identity = 0;
    if (info.fullName.trim().isNotEmpty) identity += 8;
    if (info.jobTitle.trim().isNotEmpty) identity += 8;
    if (info.email.trim().isNotEmpty) identity += 5;
    if (info.phone.trim().isNotEmpty || info.city.trim().isNotEmpty) {
      identity += 4;
    }
    total += identity;

    // Résumé — 15, proportionnel jusqu'à 200 caractères
    final summary = info.summary.trim().length;
    total += (summary / 200 * 15).round().clamp(0, 15);

    // Expériences — 25, dont 10 pour les descriptions
    if (data.experiences.isNotEmpty) {
      total += min(data.experiences.length, 2) * 7;
      final described =
          data.experiences.where((e) => e.description.trim().length > 40);
      total += min(described.length, 2) * 5;
    }

    // Formation — 10
    if (data.educations.isNotEmpty) total += 10;

    // Compétences — 15, pleines à partir de 6
    total += (data.skills.length / 6 * 15).round().clamp(0, 15);

    // Langues — 10
    if (data.languages.isNotEmpty) total += 10;

    return total.clamp(0, 100);
  }

  /// Un CV est un brouillon tant qu'il n'atteint pas un contenu présentable.
  bool get isDraft => score < 70;

  /// Intitulé affiché sous le titre dans le tableau de bord.
  String get role => data.personalInfo.jobTitle.trim().isEmpty
      ? 'Sans titre professionnel'
      : data.personalInfo.jobTitle;

  /// Ancienneté relative — remplace les « Il y a 2h » codés en dur.
  String get editedLabel {
    final d = DateTime.now().difference(updatedAt);
    if (d.inMinutes < 1) return "À l'instant";
    if (d.inMinutes < 60) return 'Il y a ${d.inMinutes} min';
    if (d.inHours < 24) return 'Il y a ${d.inHours} h';
    if (d.inDays == 1) return 'Hier';
    if (d.inDays < 30) return 'Il y a ${d.inDays} j';
    final months = d.inDays ~/ 30;
    return 'Il y a $months mois';
  }

  // ── Sérialisation (utilisée par la persistance) ───────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt.toIso8601String(),
        'targetRole': targetRole,
        'templateName': templateName,
        'version': version,
        'data': _cvDataToJson(data),
      };

  /// Les trois derniers champs sont lus avec une valeur de repli : une
  /// bibliothèque enregistrée avant leur introduction doit continuer à se
  /// charger, pas disparaître.
  static CvDocument fromJson(Map<String, dynamic> json) => CvDocument(
        id: json['id'] as String,
        title: json['title'] as String,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        targetRole: json['targetRole'] as String? ?? '',
        templateName: json['templateName'] as String? ?? 'Ravel',
        version: json['version'] as int? ?? 1,
        data: _cvDataFromJson(json['data'] as Map<String, dynamic>),
      );
}

String _newId() {
  final rand = Random();
  const chars = '0123456789abcdef';
  return List.generate(16, (_) => chars[rand.nextInt(16)]).join();
}

// ── Conversion CvData ↔ JSON ────────────────────────────────────────────

Map<String, dynamic> _cvDataToJson(CvData d) => {
      'personalInfo': {
        'fullName': d.personalInfo.fullName,
        'jobTitle': d.personalInfo.jobTitle,
        'email': d.personalInfo.email,
        'phone': d.personalInfo.phone,
        'city': d.personalInfo.city,
        'linkedIn': d.personalInfo.linkedIn,
        'summary': d.personalInfo.summary,
      },
      'experiences': [
        for (final e in d.experiences)
          {
            'id': e.id,
            'company': e.company,
            'position': e.position,
            'startDate': e.startDate,
            'endDate': e.endDate,
            'isCurrent': e.isCurrent,
            'description': e.description,
          },
      ],
      'educations': [
        for (final e in d.educations)
          {
            'id': e.id,
            'school': e.school,
            'degree': e.degree,
            'field': e.field,
            'startYear': e.startYear,
            'endYear': e.endYear,
          },
      ],
      'skills': [
        for (final s in d.skills)
          {'id': s.id, 'name': s.name, 'level': s.level.name},
      ],
      'languages': [
        for (final l in d.languages)
          {'id': l.id, 'name': l.name, 'level': l.level},
      ],
    };

CvData _cvDataFromJson(Map<String, dynamic> json) {
  final info = json['personalInfo'] as Map<String, dynamic>? ?? const {};

  String str(Map<String, dynamic> m, String k) => m[k] as String? ?? '';

  return CvData(
    personalInfo: PersonalInfo(
      fullName: str(info, 'fullName'),
      jobTitle: str(info, 'jobTitle'),
      email: str(info, 'email'),
      phone: str(info, 'phone'),
      city: str(info, 'city'),
      linkedIn: str(info, 'linkedIn'),
      summary: str(info, 'summary'),
    ),
    experiences: [
      for (final e in (json['experiences'] as List? ?? const []))
        Experience(
          id: str(e as Map<String, dynamic>, 'id'),
          company: str(e, 'company'),
          position: str(e, 'position'),
          startDate: str(e, 'startDate'),
          endDate: str(e, 'endDate'),
          isCurrent: e['isCurrent'] as bool? ?? false,
          description: str(e, 'description'),
        ),
    ],
    educations: [
      for (final e in (json['educations'] as List? ?? const []))
        Education(
          id: str(e as Map<String, dynamic>, 'id'),
          school: str(e, 'school'),
          degree: str(e, 'degree'),
          field: str(e, 'field'),
          startYear: str(e, 'startYear'),
          endYear: str(e, 'endYear'),
        ),
    ],
    skills: [
      for (final s in (json['skills'] as List? ?? const []))
        Skill(
          id: str(s as Map<String, dynamic>, 'id'),
          name: str(s, 'name'),
          level: SkillLevel.values.firstWhere(
            (l) => l.name == s['level'],
            orElse: () => SkillLevel.intermediate,
          ),
        ),
    ],
    languages: [
      for (final l in (json['languages'] as List? ?? const []))
        Language(
          id: str(l as Map<String, dynamic>, 'id'),
          name: str(l, 'name'),
          level: str(l, 'level'),
        ),
    ],
  );
}
