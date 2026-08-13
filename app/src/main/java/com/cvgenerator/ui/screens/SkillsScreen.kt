package com.cvgenerator.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.data.*
import com.cvgenerator.ui.theme.Gold
import com.cvgenerator.ui.theme.MediumGray

@Composable
fun SkillsScreen(viewModel: CvViewModel) {
    val cvData by viewModel.cvData.collectAsState()
    var skillName by remember { mutableStateOf("") }
    var skillLevel by remember { mutableStateOf(SkillLevel.INTERMEDIATE) }
    var langName by remember { mutableStateOf("") }
    var langLevel by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        Text("Compétences & Langues", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Gold)

        // Skills section
        Text("Compétences", fontWeight = FontWeight.SemiBold, fontSize = 16.sp)

        cvData.skills.forEach { skill ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(
                        horizontalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier.fillMaxWidth().padding(end = 8.dp)
                    ) {
                        Text(skill.name, fontSize = 14.sp)
                        Text(skill.level.label, fontSize = 12.sp, color = Gold)
                    }
                    Spacer(Modifier.height(4.dp))
                    LinearProgressIndicator(
                        progress = { skill.level.value },
                        modifier = Modifier.fillMaxWidth().height(4.dp),
                        color = Gold,
                        trackColor = MediumGray
                    )
                }
                IconButton(onClick = { viewModel.removeSkill(skill.id) }) {
                    Icon(Icons.Default.Close, contentDescription = null, tint = MaterialTheme.colorScheme.error, modifier = Modifier.size(16.dp))
                }
            }
        }

        // Add skill form
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(MediumGray, RoundedCornerShape(12.dp))
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text("Ajouter une compétence", fontSize = 14.sp, fontWeight = FontWeight.Medium)
            CvTextField(value = skillName, label = "Compétence", onChange = { skillName = it })

            Text("Niveau :", fontSize = 13.sp)
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                SkillLevel.entries.forEach { level ->
                    FilterChip(
                        selected = skillLevel == level,
                        onClick = { skillLevel = level },
                        label = { Text(level.label, fontSize = 11.sp) },
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = Gold,
                            selectedLabelColor = MaterialTheme.colorScheme.onPrimary
                        )
                    )
                }
            }

            Button(
                onClick = {
                    if (skillName.isNotBlank()) {
                        viewModel.addSkill(Skill(name = skillName, level = skillLevel))
                        skillName = ""
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = Gold),
                modifier = Modifier.fillMaxWidth()
            ) {
                Icon(Icons.Default.Add, contentDescription = null, tint = MaterialTheme.colorScheme.onPrimary)
                Spacer(Modifier.width(8.dp))
                Text("Ajouter", color = MaterialTheme.colorScheme.onPrimary)
            }
        }

        HorizontalDivider(color = MediumGray)

        // Languages section
        Text("Langues", fontWeight = FontWeight.SemiBold, fontSize = 16.sp)

        cvData.languages.forEach { lang ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("${lang.name} — ${lang.level}", fontSize = 14.sp)
                IconButton(onClick = { viewModel.removeLanguage(lang.id) }) {
                    Icon(Icons.Default.Close, contentDescription = null, tint = MaterialTheme.colorScheme.error, modifier = Modifier.size(16.dp))
                }
            }
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(MediumGray, RoundedCornerShape(12.dp))
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text("Ajouter une langue", fontSize = 14.sp, fontWeight = FontWeight.Medium)
            CvTextField(value = langName, label = "Langue (ex: Français)", onChange = { langName = it })
            CvTextField(value = langLevel, label = "Niveau (ex: Natif, Courant, B2)", onChange = { langLevel = it })

            Button(
                onClick = {
                    if (langName.isNotBlank() && langLevel.isNotBlank()) {
                        viewModel.addLanguage(Language(name = langName, level = langLevel))
                        langName = ""; langLevel = ""
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = Gold),
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Ajouter", color = MaterialTheme.colorScheme.onPrimary)
            }
        }

        Spacer(Modifier.height(80.dp))
    }
}
