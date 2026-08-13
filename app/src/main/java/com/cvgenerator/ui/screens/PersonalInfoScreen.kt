package com.cvgenerator.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.data.CvViewModel
import com.cvgenerator.data.PersonalInfo
import com.cvgenerator.ui.theme.Gold

@Composable
fun PersonalInfoScreen(viewModel: CvViewModel) {
    val cvData by viewModel.cvData.collectAsState()
    val info = cvData.personalInfo

    var fullName by remember { mutableStateOf(info.fullName) }
    var jobTitle by remember { mutableStateOf(info.jobTitle) }
    var email by remember { mutableStateOf(info.email) }
    var phone by remember { mutableStateOf(info.phone) }
    var city by remember { mutableStateOf(info.city) }
    var linkedIn by remember { mutableStateOf(info.linkedIn) }
    var summary by remember { mutableStateOf(info.summary) }

    fun save() {
        viewModel.updatePersonalInfo(
            PersonalInfo(fullName, jobTitle, email, phone, city, linkedIn, summary)
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Informations personnelles", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Gold)

        CvTextField(value = fullName, label = "Nom complet *") {
            fullName = it; save()
        }
        CvTextField(value = jobTitle, label = "Titre / Poste visé *") {
            jobTitle = it; save()
        }
        CvTextField(value = email, label = "Email *") {
            email = it; save()
        }
        CvTextField(value = phone, label = "Téléphone") {
            phone = it; save()
        }
        CvTextField(value = city, label = "Ville / Pays") {
            city = it; save()
        }
        CvTextField(value = linkedIn, label = "LinkedIn (optionnel)") {
            linkedIn = it; save()
        }
        CvTextField(
            value = summary,
            label = "Résumé professionnel",
            minLines = 4,
            maxLines = 6
        ) {
            summary = it; save()
        }

        Spacer(Modifier.height(80.dp))
    }
}

@Composable
fun CvTextField(
    value: String,
    label: String,
    minLines: Int = 1,
    maxLines: Int = 1,
    onChange: (String) -> Unit
) {
    OutlinedTextField(
        value = value,
        onValueChange = onChange,
        label = { Text(label) },
        modifier = Modifier.fillMaxWidth(),
        minLines = minLines,
        maxLines = maxLines,
        colors = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = Gold,
            focusedLabelColor = Gold,
        )
    )
}
