package com.cvgenerator.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable

private val DarkColorScheme = darkColorScheme(
    primary = Gold,
    onPrimary = DeepBlack,
    secondary = GoldLight,
    onSecondary = DeepBlack,
    background = DeepBlack,
    onBackground = Cream,
    surface = DarkGray,
    onSurface = TextLight,
    surfaceVariant = MediumGray,
    onSurfaceVariant = LightGray,
    error = ErrorRed,
    outline = MediumGray
)

@Composable
fun CVGeneratorTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = DarkColorScheme,
        content = content
    )
}
