package com.cvgenerator

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.core.content.FileProvider
import com.cvgenerator.data.CvViewModel
import com.cvgenerator.pdf.PdfGenerator
import com.cvgenerator.ui.onboarding.OnboardingFlow
import com.cvgenerator.ui.screens.*
import com.cvgenerator.ui.theme.CVGeneratorTheme

sealed class AppScreen {
    object Welcome : AppScreen()
    object Onboarding : AppScreen()
    object Auth : AppScreen()
    object Dashboard : AppScreen()
    data class Editor(val cvId: Int) : AppScreen()
}

class MainActivity : ComponentActivity() {

    private val viewModel: CvViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CVGeneratorTheme {
                val prefs = remember { getSharedPreferences("cvgen", Context.MODE_PRIVATE) }
                val onboardingDone = remember { prefs.getBoolean("onboarding_done", false) }
                val loggedIn = remember { prefs.getBoolean("logged_in", false) }

                val initialScreen: AppScreen = when {
                    !onboardingDone -> AppScreen.Welcome
                    !loggedIn -> AppScreen.Auth
                    else -> AppScreen.Dashboard
                }

                var screen by remember { mutableStateOf<AppScreen>(initialScreen) }

                when (val s = screen) {
                    is AppScreen.Welcome -> WelcomeScreen(
                        onGetStarted = { screen = AppScreen.Onboarding },
                        onLogin = { screen = AppScreen.Auth }
                    )

                    is AppScreen.Onboarding -> OnboardingFlow(
                        onComplete = {
                            prefs.edit().putBoolean("onboarding_done", true).apply()
                            screen = AppScreen.Auth
                        }
                    )

                    is AppScreen.Auth -> AuthScreen(
                        onAuthSuccess = {
                            prefs.edit().putBoolean("logged_in", true).apply()
                            screen = AppScreen.Dashboard
                        },
                        onBack = {
                            screen = if (prefs.getBoolean("onboarding_done", false))
                                AppScreen.Welcome else AppScreen.Onboarding
                        }
                    )

                    is AppScreen.Dashboard -> DashboardScreen(
                        onOpenEditor = { cvId -> screen = AppScreen.Editor(cvId) },
                        onCreateNew = { screen = AppScreen.Editor(0) },
                        onProfile = { }
                    )

                    is AppScreen.Editor -> EditorScreen(
                        cvId = s.cvId,
                        onBack = { screen = AppScreen.Dashboard },
                        onExport = { exportPdf() }
                    )
                }
            }
        }
    }

    private fun exportPdf() {
        try {
            val cvData = viewModel.cvData.value
            val file = PdfGenerator.generate(this, cvData)
            val uri = FileProvider.getUriForFile(this, "${packageName}.fileprovider", file)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/pdf")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(intent, "Ouvrir le CV"))
            Toast.makeText(this, "CV exporté : ${file.name}", Toast.LENGTH_LONG).show()
        } catch (e: Exception) {
            Toast.makeText(this, "Erreur lors de l'export : ${e.message}", Toast.LENGTH_LONG).show()
        }
    }
}
