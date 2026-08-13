package com.cvgenerator.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.data.CvViewModel
import com.cvgenerator.data.Experience
import com.cvgenerator.ui.theme.Gold
import com.cvgenerator.ui.theme.MediumGray

@Composable
fun ExperienceScreen(viewModel: CvViewModel) {
    val cvData by viewModel.cvData.collectAsState()
    var showForm by remember { mutableStateOf(cvData.experiences.isEmpty()) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Expériences professionnelles", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Gold)

        cvData.experiences.forEach { exp ->
            ExperienceCard(exp = exp, onDelete = { viewModel.removeExperience(exp.id) })
        }

        if (showForm) {
            ExperienceForm(
                onSave = { exp ->
                    viewModel.addExperience(exp)
                    showForm = false
                },
                onCancel = { showForm = false }
            )
        } else {
            OutlinedButton(
                onClick = { showForm = true },
                modifier = Modifier.fillMaxWidth(),
                border = ButtonDefaults.outlinedButtonBorder.copy(),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Gold)
            ) {
                Icon(Icons.Default.Add, contentDescription = null, tint = Gold)
                Spacer(Modifier.width(8.dp))
                Text("Ajouter une expérience", color = Gold)
            }
        }

        Spacer(Modifier.height(80.dp))
    }
}

@Composable
fun ExperienceCard(exp: Experience, onDelete: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MediumGray)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Top
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(exp.position, fontWeight = FontWeight.SemiBold, color = Gold)
                Text(exp.company, fontSize = 14.sp, color = MaterialTheme.colorScheme.onSurface)
                Text(
                    "${exp.startDate} — ${if (exp.isCurrent) "Présent" else exp.endDate}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            IconButton(onClick = onDelete) {
                Icon(Icons.Default.Delete, contentDescription = "Supprimer", tint = MaterialTheme.colorScheme.error)
            }
        }
    }
}

@Composable
fun ExperienceForm(onSave: (Experience) -> Unit, onCancel: () -> Unit) {
    var company by remember { mutableStateOf("") }
    var position by remember { mutableStateOf("") }
    var startDate by remember { mutableStateOf("") }
    var endDate by remember { mutableStateOf("") }
    var isCurrent by remember { mutableStateOf(false) }
    var description by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(MediumGray, RoundedCornerShape(12.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("Nouvelle expérience", fontWeight = FontWeight.SemiBold, color = Gold)

        CvTextField(value = position, label = "Poste *") { position = it }
        CvTextField(value = company, label = "Entreprise *") { company = it }
        CvTextField(value = startDate, label = "Date début (ex: Jan 2022)") { startDate = it }

        Row(verticalAlignment = Alignment.CenterVertically) {
            Checkbox(
                checked = isCurrent,
                onCheckedChange = { isCurrent = it },
                colors = CheckboxDefaults.colors(checkedColor = Gold)
            )
            Text("Poste actuel", fontSize = 14.sp)
        }

        if (!isCurrent) {
            CvTextField(value = endDate, label = "Date fin (ex: Déc 2023)") { endDate = it }
        }

        CvTextField(value = description, label = "Description", minLines = 3, maxLines = 5) { description = it }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            OutlinedButton(onClick = onCancel, modifier = Modifier.weight(1f)) {
                Text("Annuler")
            }
            Button(
                onClick = {
                    if (position.isNotBlank() && company.isNotBlank()) {
                        onSave(Experience(company = company, position = position,
                            startDate = startDate, endDate = endDate,
                            isCurrent = isCurrent, description = description))
                    }
                },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = Gold)
            ) {
                Text("Enregistrer", color = MaterialTheme.colorScheme.onPrimary)
            }
        }
    }
}
