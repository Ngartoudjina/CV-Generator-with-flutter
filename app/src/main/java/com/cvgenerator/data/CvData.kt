package com.cvgenerator.data

data class PersonalInfo(
    val fullName: String = "",
    val jobTitle: String = "",
    val email: String = "",
    val phone: String = "",
    val city: String = "",
    val linkedIn: String = "",
    val summary: String = ""
)

data class Experience(
    val id: String = java.util.UUID.randomUUID().toString(),
    val company: String = "",
    val position: String = "",
    val startDate: String = "",
    val endDate: String = "",
    val isCurrent: Boolean = false,
    val description: String = ""
)

data class Education(
    val id: String = java.util.UUID.randomUUID().toString(),
    val school: String = "",
    val degree: String = "",
    val field: String = "",
    val startYear: String = "",
    val endYear: String = ""
)

data class Skill(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String = "",
    val level: SkillLevel = SkillLevel.INTERMEDIATE
)

enum class SkillLevel(val label: String, val value: Float) {
    BEGINNER("Débutant", 0.25f),
    INTERMEDIATE("Intermédiaire", 0.5f),
    ADVANCED("Avancé", 0.75f),
    EXPERT("Expert", 1.0f)
}

data class Language(
    val id: String = java.util.UUID.randomUUID().toString(),
    val name: String = "",
    val level: String = ""
)

data class CvData(
    val personalInfo: PersonalInfo = PersonalInfo(),
    val experiences: List<Experience> = emptyList(),
    val educations: List<Education> = emptyList(),
    val skills: List<Skill> = emptyList(),
    val languages: List<Language> = emptyList()
)
