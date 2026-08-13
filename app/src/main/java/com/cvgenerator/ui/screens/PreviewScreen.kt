package com.cvgenerator.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.data.CvViewModel
import com.cvgenerator.data.Skill
import com.cvgenerator.ui.theme.Cream
import com.cvgenerator.ui.theme.DeepBlack
import com.cvgenerator.ui.theme.Gold
import com.cvgenerator.ui.theme.MediumGray

@Composable
fun PreviewScreen(viewModel: CvViewModel, onExportPdf: () -> Unit) {
    val cvData by viewModel.cvData.collectAsState()
    val info = cvData.personalInfo

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        // CV Preview — white card simulating A4
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp)
                .background(Cream, RoundedCornerShape(8.dp))
                .padding(24.dp)
        ) {
            // Header block
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(DeepBlack, RoundedCornerShape(6.dp))
                    .padding(20.dp)
            ) {
                Text(
                    info.fullName.ifBlank { "Votre Nom" },
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    color = Cream
                )
                Text(
                    info.jobTitle.ifBlank { "Titre professionnel" },
                    fontSize = 14.sp,
                    color = Gold,
                    fontWeight = FontWeight.Medium
                )
                Spacer(Modifier.height(8.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    if (info.email.isNotBlank()) CvChip(info.email)
                    if (info.phone.isNotBlank()) CvChip(info.phone)
                    if (info.city.isNotBlank()) CvChip(info.city)
                }
            }

            Spacer(Modifier.height(16.dp))

            // Summary
            if (info.summary.isNotBlank()) {
                CvSection("Profil") {
                    Text(info.summary, fontSize = 13.sp, color = Color(0xFF333333), lineHeight = 20.sp)
                }
            }

            // Experience
            if (cvData.experiences.isNotEmpty()) {
                CvSection("Expériences") {
                    cvData.experiences.forEach { exp ->
                        Column(modifier = Modifier.padding(bottom = 12.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text(exp.position, fontWeight = FontWeight.SemiBold, fontSize = 13.sp, color = DeepBlack)
                                Text(
                                    "${exp.startDate} — ${if (exp.isCurrent) "Présent" else exp.endDate}",
                                    fontSize = 11.sp, color = Color(0xFF666666)
                                )
                            }
                            Text(exp.company, fontSize = 12.sp, color = Color(0xFF444444), fontWeight = FontWeight.Medium)
                            if (exp.description.isNotBlank()) {
                                Text(exp.description, fontSize = 12.sp, color = Color(0xFF555555), lineHeight = 18.sp)
                            }
                        }
                    }
                }
            }

            // Education
            if (cvData.educations.isNotEmpty()) {
                CvSection("Formation") {
                    cvData.educations.forEach { edu ->
                        Column(modifier = Modifier.padding(bottom = 10.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text(edu.degree, fontWeight = FontWeight.SemiBold, fontSize = 13.sp, color = DeepBlack)
                                Text("${edu.startYear} — ${edu.endYear}", fontSize = 11.sp, color = Color(0xFF666666))
                            }
                            Text(edu.school, fontSize = 12.sp, color = Color(0xFF444444))
                            if (edu.field.isNotBlank()) Text(edu.field, fontSize = 12.sp, color = Color(0xFF666666))
                        }
                    }
                }
            }

            // Skills
            if (cvData.skills.isNotEmpty()) {
                CvSection("Compétences") {
                    cvData.skills.chunked(2).forEach { row ->
                        Row(modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                            row.forEach { skill ->
                                SkillBar(skill = skill, modifier = Modifier.weight(1f))
                            }
                            if (row.size == 1) Spacer(Modifier.weight(1f))
                        }
                    }
                }
            }

            // Languages
            if (cvData.languages.isNotEmpty()) {
                CvSection("Langues") {
                    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        cvData.languages.forEach { lang ->
                            Text("${lang.name} · ${lang.level}", fontSize = 12.sp, color = Color(0xFF444444))
                        }
                    }
                }
            }
        }

        Spacer(Modifier.height(16.dp))

        // Export button
        Button(
            onClick = onExportPdf,
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp)
                .height(52.dp),
            colors = ButtonDefaults.buttonColors(containerColor = Gold),
            shape = RoundedCornerShape(12.dp)
        ) {
            Text("Exporter en PDF", color = DeepBlack, fontWeight = FontWeight.Bold, fontSize = 16.sp)
        }

        Spacer(Modifier.height(32.dp))
    }
}

@Composable
fun CvSection(title: String, content: @Composable () -> Unit) {
    Column(modifier = Modifier.fillMaxWidth().padding(bottom = 16.dp)) {
        Text(
            title.uppercase(),
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFFC8A96E),
            letterSpacing = 2.sp
        )
        HorizontalDivider(color = Color(0xFFC8A96E), thickness = 1.dp, modifier = Modifier.padding(vertical = 6.dp))
        content()
    }
}

@Composable
fun CvChip(text: String) {
    Text(text, fontSize = 11.sp, color = Color(0xFFCCCCCC))
}

@Composable
fun SkillBar(skill: Skill, modifier: Modifier = Modifier) {
    Column(modifier = modifier) {
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            Text(skill.name, fontSize = 12.sp, color = Color(0xFF333333))
            Text(skill.level.label, fontSize = 10.sp, color = Color(0xFF888888))
        }
        Spacer(Modifier.height(3.dp))
        LinearProgressIndicator(
            progress = { skill.level.value },
            modifier = Modifier.fillMaxWidth().height(3.dp),
            color = Color(0xFFC8A96E),
            trackColor = Color(0xFFDDDDDD)
        )
    }
}
