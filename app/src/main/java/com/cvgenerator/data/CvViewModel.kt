package com.cvgenerator.data

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class CvViewModel : ViewModel() {

    private val _cvData = MutableStateFlow(CvData())
    val cvData: StateFlow<CvData> = _cvData.asStateFlow()

    private val _currentStep = MutableStateFlow(0)
    val currentStep: StateFlow<Int> = _currentStep.asStateFlow()

    val totalSteps = 5

    fun updatePersonalInfo(info: PersonalInfo) {
        _cvData.update { it.copy(personalInfo = info) }
    }

    fun addExperience(exp: Experience) {
        _cvData.update { it.copy(experiences = it.experiences + exp) }
    }

    fun updateExperience(exp: Experience) {
        _cvData.update {
            it.copy(experiences = it.experiences.map { e -> if (e.id == exp.id) exp else e })
        }
    }

    fun removeExperience(id: String) {
        _cvData.update { it.copy(experiences = it.experiences.filter { e -> e.id != id }) }
    }

    fun addEducation(edu: Education) {
        _cvData.update { it.copy(educations = it.educations + edu) }
    }

    fun updateEducation(edu: Education) {
        _cvData.update {
            it.copy(educations = it.educations.map { e -> if (e.id == edu.id) edu else e })
        }
    }

    fun removeEducation(id: String) {
        _cvData.update { it.copy(educations = it.educations.filter { e -> e.id != id }) }
    }

    fun addSkill(skill: Skill) {
        _cvData.update { it.copy(skills = it.skills + skill) }
    }

    fun removeSkill(id: String) {
        _cvData.update { it.copy(skills = it.skills.filter { s -> s.id != id }) }
    }

    fun addLanguage(lang: Language) {
        _cvData.update { it.copy(languages = it.languages + lang) }
    }

    fun removeLanguage(id: String) {
        _cvData.update { it.copy(languages = it.languages.filter { l -> l.id != id }) }
    }

    fun nextStep() {
        if (_currentStep.value < totalSteps - 1) _currentStep.update { it + 1 }
    }

    fun previousStep() {
        if (_currentStep.value > 0) _currentStep.update { it - 1 }
    }

    fun goToStep(step: Int) {
        _currentStep.value = step.coerceIn(0, totalSteps - 1)
    }
}
