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
import com.cvgenerator.data.Education
import com.cvgenerator.ui.theme.Gold
import com.cvgenerator.ui.theme.MediumGray

@Composable
fun EducationScreen(viewModel: CvViewModel) {
    val cvData by viewModel.cvData.collectAsState()
    var showForm by remember { mutableStateOf(cvData.educations.isEmpty()) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Formation", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Gold)

        cvData.educations.forEach { edu ->
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
                        Text(edu.degree, fontWeight = FontWeight.SemiBold, color = Gold)
                        Text(edu.school, fontSize = 14.sp)
                        if (edu.field.isNotBlank()) Text(edu.field, fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        Text("${edu.startYear} — ${edu.endYear}", fontSize = 12.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                    IconButton(onClick = { viewModel.removeEducation(edu.id) }) {
                        Icon(Icons.Default.Delete, contentDescription = null, tint = MaterialTheme.colorScheme.error)
                    }
                }
            }
        }

        if (showForm) {
            EducationForm(
                onSave = { viewModel.addEducation(it); showForm = false },
                onCancel = { showForm = false }
            )
        } else {
            OutlinedButton(
                onClick = { showForm = true },
                modifier = Modifier.fillMaxWidth(),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Gold)
            ) {
                Icon(Icons.Default.Add, contentDescription = null, tint = Gold)
                Spacer(Modifier.width(8.dp))
                Text("Ajouter une formation", color = Gold)
            }
        }

        Spacer(Modifier.height(80.dp))
    }
}

@Composable
fun EducationForm(onSave: (Education) -> Unit, onCancel: () -> Unit) {
    var school by remember { mutableStateOf("") }
    var degree by remember { mutableStateOf("") }
    var field by remember { mutableStateOf("") }
    var startYear by remember { mutableStateOf("") }
    var endYear by remember { mutableStateOf("") }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(MediumGray, RoundedCornerShape(12.dp))
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text("Nouvelle formation", fontWeight = FontWeight.SemiBold, color = Gold)

        CvTextField(value = degree, label = "Diplôme *") { degree = it }
        CvTextField(value = school, label = "École / Université *") { school = it }
        CvTextField(value = field, label = "Domaine / Spécialité") { field = it }
        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            CvTextField(value = startYear, label = "Année début", onChange = { startYear = it }, modifier = Modifier.weight(1f))
            CvTextField(value = endYear, label = "Année fin", onChange = { endYear = it }, modifier = Modifier.weight(1f))
        }

        Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            OutlinedButton(onClick = onCancel, modifier = Modifier.weight(1f)) { Text("Annuler") }
            Button(
                onClick = {
                    if (degree.isNotBlank() && school.isNotBlank())
                        onSave(Education(school = school, degree = degree, field = field, startYear = startYear, endYear = endYear))
                },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = Gold)
            ) { Text("Enregistrer", color = MaterialTheme.colorScheme.onPrimary) }
        }
    }
}

@Composable
fun CvTextField(value: String, label: String, onChange: (String) -> Unit, modifier: Modifier = Modifier) {
    OutlinedTextField(
        value = value,
        onValueChange = onChange,
        label = { Text(label) },
        modifier = modifier.fillMaxWidth(),
        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = Gold, focusedLabelColor = Gold)
    )
}
