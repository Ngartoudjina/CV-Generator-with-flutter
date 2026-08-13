import 'package:flutter/foundation.dart';

import '../models/cv_data.dart';

/// Port de `data/CvViewModel.kt`.
///
/// `MutableStateFlow` + `collectAsState()` → `ChangeNotifier` + `Consumer` /
/// `context.watch()`. Chaque mutation reconstruit l'état de façon immuable
/// (comme `_cvData.update { it.copy(...) }`) puis notifie les écouteurs.
class CvModel extends ChangeNotifier {
  CvData _cvData = const CvData();
  int _currentStep = 0;

  static const int totalSteps = 5;

  CvData get cvData => _cvData;
  int get currentStep => _currentStep;

  void _update(CvData next) {
    _cvData = next;
    notifyListeners();
  }

  // ── Informations personnelles ──────────────────────────────
  void updatePersonalInfo(PersonalInfo info) {
    _update(_cvData.copyWith(personalInfo: info));
  }

  // ── Expériences ────────────────────────────────────────────
  void addExperience(Experience exp) {
    _update(_cvData.copyWith(experiences: [..._cvData.experiences, exp]));
  }

  void updateExperience(Experience exp) {
    _update(_cvData.copyWith(
      experiences: [
        for (final e in _cvData.experiences) e.id == exp.id ? exp : e,
      ],
    ));
  }

  void removeExperience(String id) {
    _update(_cvData.copyWith(
      experiences: _cvData.experiences.where((e) => e.id != id).toList(),
    ));
  }

  // ── Formation ──────────────────────────────────────────────
  void addEducation(Education edu) {
    _update(_cvData.copyWith(educations: [..._cvData.educations, edu]));
  }

  void updateEducation(Education edu) {
    _update(_cvData.copyWith(
      educations: [
        for (final e in _cvData.educations) e.id == edu.id ? edu : e,
      ],
    ));
  }

  void removeEducation(String id) {
    _update(_cvData.copyWith(
      educations: _cvData.educations.where((e) => e.id != id).toList(),
    ));
  }

  // ── Compétences ────────────────────────────────────────────
  void addSkill(Skill skill) {
    _update(_cvData.copyWith(skills: [..._cvData.skills, skill]));
  }

  void removeSkill(String id) {
    _update(_cvData.copyWith(
      skills: _cvData.skills.where((s) => s.id != id).toList(),
    ));
  }

  // ── Langues ────────────────────────────────────────────────
  void addLanguage(Language lang) {
    _update(_cvData.copyWith(languages: [..._cvData.languages, lang]));
  }

  void removeLanguage(String id) {
    _update(_cvData.copyWith(
      languages: _cvData.languages.where((l) => l.id != id).toList(),
    ));
  }

  // ── Navigation par étapes ──────────────────────────────────
  void nextStep() {
    if (_currentStep < totalSteps - 1) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  void goToStep(int step) {
    _currentStep = step.clamp(0, totalSteps - 1);
    notifyListeners();
  }
}
