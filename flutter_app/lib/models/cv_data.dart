import 'dart:math';

/// Port de `data/CvData.kt`.
///
/// Les `data class` Kotlin deviennent des classes immuables avec `copyWith`
/// (l'équivalent Dart de `copy()`).

String _newId() {
  // Équivalent léger de java.util.UUID.randomUUID().toString()
  final rand = Random();
  const chars = '0123456789abcdef';
  String block(int n) =>
      List.generate(n, (_) => chars[rand.nextInt(16)]).join();
  return '${block(8)}-${block(4)}-${block(4)}-${block(4)}-${block(12)}';
}

class PersonalInfo {
  const PersonalInfo({
    this.fullName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.city = '',
    this.linkedIn = '',
    this.summary = '',
  });

  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String city;
  final String linkedIn;
  final String summary;

  PersonalInfo copyWith({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phone,
    String? city,
    String? linkedIn,
    String? summary,
  }) {
    return PersonalInfo(
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      linkedIn: linkedIn ?? this.linkedIn,
      summary: summary ?? this.summary,
    );
  }
}

class Experience {
  Experience({
    String? id,
    this.company = '',
    this.position = '',
    this.startDate = '',
    this.endDate = '',
    this.isCurrent = false,
    this.description = '',
  }) : id = id ?? _newId();

  final String id;
  final String company;
  final String position;
  final String startDate;
  final String endDate;
  final bool isCurrent;
  final String description;

  Experience copyWith({
    String? company,
    String? position,
    String? startDate,
    String? endDate,
    bool? isCurrent,
    String? description,
  }) {
    return Experience(
      id: id,
      company: company ?? this.company,
      position: position ?? this.position,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      description: description ?? this.description,
    );
  }
}

class Education {
  Education({
    String? id,
    this.school = '',
    this.degree = '',
    this.field = '',
    this.startYear = '',
    this.endYear = '',
  }) : id = id ?? _newId();

  final String id;
  final String school;
  final String degree;
  final String field;
  final String startYear;
  final String endYear;

  Education copyWith({
    String? school,
    String? degree,
    String? field,
    String? startYear,
    String? endYear,
  }) {
    return Education(
      id: id,
      school: school ?? this.school,
      degree: degree ?? this.degree,
      field: field ?? this.field,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
    );
  }
}

/// Port de `enum class SkillLevel(val label: String, val value: Float)`.
enum SkillLevel {
  beginner('Débutant', 0.25),
  intermediate('Intermédiaire', 0.5),
  advanced('Avancé', 0.75),
  expert('Expert', 1.0);

  const SkillLevel(this.label, this.value);

  final String label;
  final double value;
}

class Skill {
  Skill({
    String? id,
    this.name = '',
    this.level = SkillLevel.intermediate,
  }) : id = id ?? _newId();

  final String id;
  final String name;
  final SkillLevel level;

  Skill copyWith({String? name, SkillLevel? level}) {
    return Skill(id: id, name: name ?? this.name, level: level ?? this.level);
  }
}

class Language {
  Language({String? id, this.name = '', this.level = ''}) : id = id ?? _newId();

  final String id;
  final String name;
  final String level;

  Language copyWith({String? name, String? level}) {
    return Language(
      id: id,
      name: name ?? this.name,
      level: level ?? this.level,
    );
  }
}

class CvData {
  const CvData({
    this.personalInfo = const PersonalInfo(),
    this.experiences = const [],
    this.educations = const [],
    this.skills = const [],
    this.languages = const [],
  });

  final PersonalInfo personalInfo;
  final List<Experience> experiences;
  final List<Education> educations;
  final List<Skill> skills;
  final List<Language> languages;

  CvData copyWith({
    PersonalInfo? personalInfo,
    List<Experience>? experiences,
    List<Education>? educations,
    List<Skill>? skills,
    List<Language>? languages,
  }) {
    return CvData(
      personalInfo: personalInfo ?? this.personalInfo,
      experiences: experiences ?? this.experiences,
      educations: educations ?? this.educations,
      skills: skills ?? this.skills,
      languages: languages ?? this.languages,
    );
  }
}
