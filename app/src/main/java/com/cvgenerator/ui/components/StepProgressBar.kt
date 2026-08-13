package com.cvgenerator.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.ui.theme.Gold
import com.cvgenerator.ui.theme.MediumGray

val stepLabels = listOf("Identité", "Expériences", "Formation", "Compétences", "Aperçu")

@Composable
fun StepProgressBar(
    currentStep: Int,
    totalSteps: Int,
    onStepClick: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            repeat(totalSteps) { index ->
                val isCompleted = index < currentStep
                val isCurrent = index == currentStep
                val color = when {
                    isCompleted || isCurrent -> Gold
                    else -> MediumGray
                }

                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                        modifier = Modifier
                            .size(32.dp)
                            .clip(CircleShape)
                            .background(color)
                            .clickable { onStepClick(index) },
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = if (isCompleted) "✓" else "${index + 1}",
                            color = if (isCompleted || isCurrent) MaterialTheme.colorScheme.onPrimary
                            else MaterialTheme.colorScheme.onSurfaceVariant,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                    }
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = stepLabels.getOrElse(index) { "" },
                        fontSize = 9.sp,
                        color = if (isCurrent) Gold else MaterialTheme.colorScheme.onSurfaceVariant,
                        fontWeight = if (isCurrent) FontWeight.SemiBold else FontWeight.Normal
                    )
                }

                if (index < totalSteps - 1) {
                    val progress by animateFloatAsState(
                        targetValue = if (index < currentStep) 1f else 0f,
                        animationSpec = tween(300), label = "progress"
                    )
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(2.dp)
                            .padding(bottom = 16.dp)
                    ) {
                        Box(modifier = Modifier.fillMaxSize().background(MediumGray))
                        Box(
                            modifier = Modifier
                                .fillMaxHeight()
                                .fillMaxWidth(progress)
                                .background(Gold)
                        )
                    }
                }
            }
        }
    }
}
