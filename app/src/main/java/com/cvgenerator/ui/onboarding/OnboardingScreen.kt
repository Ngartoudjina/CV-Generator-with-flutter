package com.cvgenerator.ui.onboarding

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.cvgenerator.R
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

// ── Colors ───────────────────────────────────────────────────
private val OBAccent    = Color(0xFF6C40E0)
private val OBAccentCo  = Color(0xFFC49AEC)
private val OBBg        = Color(0xFFF1ECFB)
private val OBCard      = Color(0xFFFFFFFF)
private val OBInk       = Color(0xFF1C1626)
private val OBPaper     = Color(0xFFFFFFFF)
private val OBInkPaper  = Color(0xFF241B30)
private val OBDark      = Color(0xFF0D0920)
private val OBDarkMid   = Color(0xFF180C30)
private val OBWhite     = Color(0xFFEFEBFF)

// ── Main flow ────────────────────────────────────────────────
@OptIn(ExperimentalAnimationApi::class)
@Composable
fun OnboardingFlow(onComplete: () -> Unit) {
    var step by remember { mutableStateOf(0) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(OBBg)
    ) {
        AnimatedContent(
            targetState = step,
            transitionSpec = {
                if (targetState > initialState) {
                    (slideInHorizontally { it } + fadeIn()) togetherWith
                            (slideOutHorizontally { -it } + fadeOut())
                } else {
                    (slideInHorizontally { -it } + fadeIn()) togetherWith
                            (slideOutHorizontally { it } + fadeOut())
                }
            },
            label = "ob_step"
        ) { s ->
            when (s) {
                0 -> SplashScreen(onNext = { step = 1 })
                1 -> FeatureWriteScreen(onNext = { step = 2 }, onSkip = { step = 4 })
                2 -> FeatureScoreScreen(onNext = { step = 3 }, onSkip = { step = 4 })
                3 -> FeatureExportScreen(onNext = { step = 4 }, onSkip = { step = 4 })
                4 -> PersonaScreen(onNext = { step = 5 })
                5 -> SuccessScreen(onComplete = onComplete, onRestart = { step = 0 })
            }
        }
    }
}

// ── Shared atoms ─────────────────────────────────────────────
@Composable
private fun Eyebrow(text: String) {
    Text(
        text = text.uppercase(),
        color = OBAccent,
        fontSize = 11.sp,
        fontWeight = FontWeight.Medium,
        letterSpacing = 2.sp
    )
}

@Composable
private fun OBTitle(text: String) {
    Text(
        text = text,
        color = OBInk,
        fontSize = 28.sp,
        fontWeight = FontWeight.Bold,
        lineHeight = 33.sp
    )
}

@Composable
private fun OBSub(text: String) {
    Text(
        text = text,
        color = OBInk.copy(alpha = 0.55f),
        fontSize = 15.sp,
        lineHeight = 22.sp
    )
}

@Composable
private fun PrimaryBtn(text: String, onClick: () -> Unit, enabled: Boolean = true) {
    Button(
        onClick = onClick,
        enabled = enabled,
        modifier = Modifier
            .fillMaxWidth()
            .height(54.dp),
        shape = RoundedCornerShape(15.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = OBAccent,
            disabledContainerColor = OBAccent.copy(alpha = 0.45f)
        )
    ) {
        Text("$text  →", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = OBBg)
    }
}

@Composable
private fun GhostBtn(text: String, onClick: () -> Unit) {
    TextButton(onClick = onClick, modifier = Modifier.fillMaxWidth()) {
        Text(text, color = OBInk.copy(alpha = 0.5f), fontSize = 14.sp, fontWeight = FontWeight.Medium)
    }
}

@Composable
private fun ProgressDots(count: Int, active: Int) {
    Row(
        horizontalArrangement = Arrangement.Center,
        modifier = Modifier.fillMaxWidth()
    ) {
        repeat(count) { i ->
            val width by animateDpAsState(
                targetValue = if (i == active) 22.dp else 6.dp,
                animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
                label = "dot_$i"
            )
            Box(
                modifier = Modifier
                    .padding(horizontal = 3.5.dp)
                    .width(width)
                    .height(6.dp)
                    .clip(RoundedCornerShape(9.dp))
                    .background(if (i == active) OBAccent else OBInk.copy(alpha = 0.18f))
            )
        }
    }
}

@Composable
private fun ObHeader(onSkip: (() -> Unit)? = null) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Image(
            painter = painterResource(R.drawable.logo_icon),
            contentDescription = null,
            modifier = Modifier.size(64.dp),
            contentScale = ContentScale.Fit
        )
        if (onSkip != null) {
            TextButton(onClick = onSkip) {
                Text("Passer", color = OBInk.copy(alpha = 0.45f), fontSize = 12.sp)
            }
        } else {
            Spacer(Modifier.size(30.dp))
        }
    }
}

@Composable
private fun ObFooter(dotsActive: Int, onNext: () -> Unit, label: String = "Suivant") {
    Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
        ProgressDots(count = 3, active = dotsActive)
        PrimaryBtn(text = label, onClick = onNext)
    }
}

// ── Screen 0 · Splash ────────────────────────────────────────
@Composable
private fun SplashScreen(onNext: () -> Unit) {
    Box(
        modifier = Modifier.fillMaxSize()
            .background(Brush.verticalGradient(listOf(OBDark, OBDarkMid, OBDark)))
    ) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Spacer(Modifier.height(60.dp))

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.Center
        ) {
            Image(
                painter = painterResource(R.drawable.logo_icon),
                contentDescription = "CV Generator",
                modifier = Modifier
                    .fillMaxWidth()
                    .height(220.dp),
                contentScale = ContentScale.Fit
            )

            Text(
                "IA · ERA",
                fontSize = 12.sp,
                color = OBAccentCo,
                letterSpacing = 4.sp,
                modifier = Modifier.padding(top = 12.dp)
            )

            Spacer(Modifier.height(24.dp))

            Text(
                "Votre parcours, sublimé par l'intelligence artificielle.",
                fontSize = 22.sp,
                color = OBWhite.copy(alpha = 0.80f),
                textAlign = TextAlign.Center,
                lineHeight = 30.sp,
                fontStyle = FontStyle.Italic,
                modifier = Modifier.padding(horizontal = 16.dp)
            )
        }

        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Box(
                modifier = Modifier.fillMaxWidth().height(54.dp)
                    .clip(RoundedCornerShape(15.dp))
                    .background(Brush.linearGradient(listOf(OBAccent, Color(0xFF9B6AEE))))
                    .clickable(onClick = onNext),
                contentAlignment = Alignment.Center
            ) {
                Text("Commencer  →", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color.White)
            }
            Box(
                modifier = Modifier.fillMaxWidth().height(48.dp)
                    .clip(RoundedCornerShape(15.dp))
                    .border(1.dp, OBWhite.copy(alpha = 0.22f), RoundedCornerShape(15.dp))
                    .clickable { },
                contentAlignment = Alignment.Center
            ) {
                Text("J'ai déjà un compte", color = OBWhite.copy(0.65f), fontSize = 14.sp, fontWeight = FontWeight.Medium)
            }
        }
    }
    } // end dark Box
}

// ── Screen 1 · FeatureWrite ──────────────────────────────────
@Composable
private fun FeatureWriteScreen(onNext: () -> Unit, onSkip: () -> Unit) {
    val raw = "jai géré une équipe et augmenté les ventes"
    var typed by remember { mutableStateOf("") }
    var phase by remember { mutableStateOf("typing") }

    val blink by rememberInfiniteTransition(label = "blink").animateFloat(
        initialValue = 1f, targetValue = 0f,
        animationSpec = infiniteRepeatable(tween(500), RepeatMode.Reverse),
        label = "blink_alpha"
    )

    LaunchedEffect(Unit) {
        delay(400)
        for (i in 1..raw.length) {
            typed = raw.substring(0, i)
            delay(42)
        }
        delay(500)
        phase = "think"
        delay(1000)
        phase = "done"
    }

    val outputAlpha by animateFloatAsState(
        targetValue = if (phase == "done") 1f else 0.25f, label = "out_alpha"
    )
    val outputOffset by animateDpAsState(
        targetValue = if (phase == "done") 0.dp else 10.dp, label = "out_offset"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(28.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        ObHeader(onSkip = onSkip)
        Eyebrow("01 · Rédaction IA")
        OBTitle("Décrivez.\nL'IA rédige.")
        OBSub("Écrivez comme vous parlez. L'IA transforme vos phrases en accomplissements percutants.")

        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.Center
        ) {
            // Raw input bubble
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                color = OBCard,
                border = BorderStroke(1.dp, OBInk.copy(alpha = 0.07f))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Vous écrivez", color = OBInk.copy(alpha = 0.4f), fontSize = 10.sp, letterSpacing = 1.sp)
                    Spacer(Modifier.height(8.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(typed, color = OBInk.copy(alpha = 0.85f), fontSize = 15.sp)
                        if (phase == "typing") {
                            Box(
                                modifier = Modifier
                                    .width(2.dp)
                                    .height(18.dp)
                                    .alpha(blink)
                                    .background(OBAccent)
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(14.dp))

            // AI indicator
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.padding(start = 4.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(30.dp)
                        .clip(RoundedCornerShape(9.dp))
                        .background(OBAccent.copy(alpha = 0.14f)),
                    contentAlignment = Alignment.Center
                ) {
                    Text("✦", color = OBAccent, fontSize = 15.sp)
                }
                Spacer(Modifier.width(10.dp))
                Text(
                    if (phase == "done") "Reformulé par l'IA" else "L'IA reformule…",
                    color = OBInk.copy(alpha = 0.5f),
                    fontSize = 12.sp
                )
            }

            Spacer(Modifier.height(14.dp))

            // Polished output
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .offset(y = outputOffset)
                    .alpha(outputAlpha),
                shape = RoundedCornerShape(16.dp),
                color = OBAccent.copy(alpha = 0.08f),
                border = BorderStroke(1.dp, OBAccent.copy(alpha = 0.35f))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Résultat pro", color = OBAccent, fontSize = 10.sp, letterSpacing = 1.sp)
                    Spacer(Modifier.height(8.dp))
                    Text(
                        buildAnnotatedString {
                            withStyle(SpanStyle(color = OBAccent, fontWeight = FontWeight.Bold)) { append("Piloté") }
                            append(" une équipe de 6 et ")
                            withStyle(SpanStyle(color = OBAccent, fontWeight = FontWeight.Bold)) { append("accru le chiffre d'affaires de 32 %") }
                            append(" en 9 mois.")
                        },
                        fontSize = 15.sp,
                        color = OBInk,
                        lineHeight = 22.sp,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
        }

        ObFooter(dotsActive = 0, onNext = onNext)
    }
}

// ── Screen 2 · FeatureScore ──────────────────────────────────
@Composable
private fun FeatureScoreScreen(onNext: () -> Unit, onSkip: () -> Unit) {
    var targetScore by remember { mutableStateOf(0) }
    var lit by remember { mutableStateOf(0) }

    val animScore by animateIntAsState(
        targetValue = targetScore,
        animationSpec = tween(1400, easing = FastOutSlowInEasing),
        label = "score"
    )
    val sweepAngle = (animScore / 100f) * 360f

    LaunchedEffect(Unit) {
        delay(300)
        targetScore = 92
        delay(700)
        lit = 1
        delay(300)
        lit = 2
        delay(300)
        lit = 3
    }

    val factors = listOf("Verbes d'action", "Résultats chiffrés", "Mots-clés ATS")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(28.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        ObHeader(onSkip = onSkip)
        Eyebrow("02 · Score de crédibilité")
        OBTitle("Mesurez votre impact,\nen direct.")

        Column(
            modifier = Modifier.weight(1f),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            // Score ring
            Box(contentAlignment = Alignment.Center, modifier = Modifier.size(180.dp)) {
                Canvas(modifier = Modifier.fillMaxSize()) {
                    val stroke = Stroke(width = 12.dp.toPx(), cap = StrokeCap.Round)
                    val pad = 12.dp.toPx()
                    val arcSize = Size(this.size.width - pad * 2, this.size.height - pad * 2)
                    val topLeft = Offset(pad, pad)
                    drawArc(
                        color = OBInk.copy(alpha = 0.08f),
                        startAngle = -90f, sweepAngle = 360f, useCenter = false,
                        topLeft = topLeft, size = arcSize, style = stroke
                    )
                    drawArc(
                        brush = Brush.sweepGradient(
                            listOf(OBAccent, OBAccentCo, Color(0xFF9B6AEE), OBAccent),
                            center = center
                        ),
                        startAngle = -90f, sweepAngle = sweepAngle, useCenter = false,
                        topLeft = topLeft, size = arcSize, style = stroke
                    )
                }
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("$animScore", fontSize = 52.sp, fontWeight = FontWeight.ExtraBold, color = OBInk, lineHeight = 52.sp)
                    Text("/ 100", fontSize = 12.sp, color = OBInk.copy(alpha = 0.45f))
                }
            }

            Spacer(Modifier.height(30.dp))

            // Factor checklist
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                factors.forEachIndexed { idx, label ->
                    val n = idx + 1
                    val isLit = lit >= n
                    val alpha by animateFloatAsState(targetValue = if (isLit) 1f else 0.4f, label = "f_alpha_$n")
                    val offset by animateDpAsState(targetValue = if (isLit) 0.dp else (-6).dp, label = "f_off_$n")
                    val checkBg by animateColorAsState(
                        targetValue = if (isLit) OBAccent else OBInk.copy(alpha = 0.12f), label = "check_$n"
                    )

                    Surface(
                        modifier = Modifier
                            .fillMaxWidth()
                            .offset(x = offset)
                            .alpha(alpha),
                        shape = RoundedCornerShape(13.dp),
                        color = OBCard,
                        border = BorderStroke(1.dp, if (isLit) OBAccent.copy(alpha = 0.3f) else OBInk.copy(alpha = 0.06f))
                    ) {
                        Row(modifier = Modifier.padding(13.dp), verticalAlignment = Alignment.CenterVertically) {
                            Box(
                                modifier = Modifier.size(22.dp).clip(CircleShape).background(checkBg),
                                contentAlignment = Alignment.Center
                            ) {
                                if (isLit) Text("✓", color = OBBg, fontSize = 11.sp, fontWeight = FontWeight.ExtraBold)
                            }
                            Spacer(Modifier.width(12.dp))
                            Text(label, fontSize = 15.sp, color = OBInk, fontWeight = FontWeight.Medium)
                        }
                    }
                }
            }
        }

        ObFooter(dotsActive = 1, onNext = onNext)
    }
}

// ── Screen 3 · FeatureExport ─────────────────────────────────
@Composable
private fun FeatureExportScreen(onNext: () -> Unit, onSkip: () -> Unit) {
    var show by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) { delay(300); show = true }

    val cardOffset by animateDpAsState(
        targetValue = if (show) 0.dp else 14.dp,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy),
        label = "card_off"
    )
    val badgeAlpha by animateFloatAsState(
        targetValue = if (show) 1f else 0f,
        animationSpec = tween(500, delayMillis = 800),
        label = "badge_alpha"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(28.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        ObHeader(onSkip = onSkip)
        Eyebrow("03 · Export & ATS")
        OBTitle("Un PDF impeccable,\nlu par les robots.")
        OBSub("Mise en page soignée à l'écran, structure parfaitement lisible par les filtres ATS.")

        Box(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth(),
            contentAlignment = Alignment.Center
        ) {
            // Mock CV card
            Surface(
                modifier = Modifier
                    .width(200.dp)
                    .offset(y = cardOffset),
                shape = RoundedCornerShape(10.dp),
                color = OBPaper,
                shadowElevation = 16.dp
            ) {
                Column(modifier = Modifier.padding(20.dp)) {
                    Text("Amina Diallo", fontSize = 20.sp, fontWeight = FontWeight.SemiBold, color = OBInkPaper)
                    Text("Chef de projet · Marketing", fontSize = 9.sp, color = OBAccent, letterSpacing = 1.sp)
                    HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp), color = OBInkPaper.copy(alpha = 0.15f))
                    Text("Expérience", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = OBInkPaper, letterSpacing = 0.5.sp)
                    Spacer(Modifier.height(8.dp))
                    listOf(0.85f to true, 0.70f to false, 0.78f to false).forEachIndexed { i, (w, strong) ->
                        val lineW by animateFloatAsState(
                            targetValue = if (show) w else 0f,
                            animationSpec = tween(600, delayMillis = 300 + i * 100),
                            label = "line_$i"
                        )
                        Box(
                            modifier = Modifier
                                .fillMaxWidth(lineW)
                                .height(6.dp)
                                .clip(RoundedCornerShape(3.dp))
                                .background(OBInkPaper.copy(alpha = if (strong) 0.55f else 0.16f))
                        )
                        Spacer(Modifier.height(6.dp))
                    }
                    Spacer(Modifier.height(8.dp))
                    Text("Compétences", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = OBInkPaper, letterSpacing = 0.5.sp)
                    Spacer(Modifier.height(8.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(5.dp)) {
                        listOf("Stratégie", "SEO", "Figma").forEach { tag ->
                            val tagAlpha by animateFloatAsState(
                                targetValue = if (show) 1f else 0f,
                                animationSpec = tween(400, delayMillis = 600),
                                label = "tag_$tag"
                            )
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(20.dp))
                                    .background(OBAccent.copy(alpha = 0.18f))
                                    .alpha(tagAlpha)
                                    .padding(horizontal = 8.dp, vertical = 3.dp)
                            ) {
                                Text(tag, fontSize = 8.sp, color = OBInkPaper)
                            }
                        }
                    }
                }
            }

            // ATS badge
            Box(
                modifier = Modifier
                    .align(Alignment.TopEnd)
                    .offset(y = 16.dp)
                    .alpha(badgeAlpha)
                    .clip(RoundedCornerShape(9.dp))
                    .background(OBAccent)
                    .padding(horizontal = 12.dp, vertical = 7.dp)
            ) {
                Text("✓ Compatible ATS", color = OBBg, fontSize = 11.sp, fontWeight = FontWeight.Medium)
            }

            // PDF badge
            Box(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .offset(y = (-16).dp)
                    .alpha(badgeAlpha)
                    .clip(RoundedCornerShape(8.dp))
                    .background(OBCard)
                    .border(1.dp, OBInk.copy(alpha = 0.12f), RoundedCornerShape(8.dp))
                    .padding(horizontal = 11.dp, vertical = 6.dp)
            ) {
                Text("PDF · A4 · 300dpi", fontSize = 10.sp, color = OBInk)
            }
        }

        ObFooter(dotsActive = 2, onNext = onNext)
    }
}

// ── Screen 4 · Persona ───────────────────────────────────────
@Composable
private fun PersonaScreen(onNext: () -> Unit) {
    var role by remember { mutableStateOf<String?>(null) }
    var sector by remember { mutableStateOf<String?>(null) }
    val ready = role != null && sector != null

    val roles = listOf("Étudiant·e", "Cadre", "Entrepreneur·e", "En reconversion")
    val sectors = listOf("Tech", "Marketing", "Finance", "Santé", "Design", "Éducation")

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(28.dp),
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Spacer(Modifier.height(40.dp))
        Eyebrow("Pour commencer")
        Spacer(Modifier.height(4.dp))
        OBTitle("Parlez-nous de vous.")

        Column(
            modifier = Modifier.weight(1f),
            verticalArrangement = Arrangement.Center
        ) {
            Text("Vous êtes…", color = OBInk.copy(alpha = 0.45f), fontSize = 11.sp, letterSpacing = 1.sp)
            Spacer(Modifier.height(12.dp))
            roles.chunked(2).forEach { row ->
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(9.dp)) {
                    row.forEach { r ->
                        SelectChip(label = r, selected = role == r, onClick = { role = r }, modifier = Modifier.weight(1f))
                    }
                }
                Spacer(Modifier.height(9.dp))
            }

            Spacer(Modifier.height(24.dp))

            Text("Votre secteur", color = OBInk.copy(alpha = 0.45f), fontSize = 11.sp, letterSpacing = 1.sp)
            Spacer(Modifier.height(12.dp))
            sectors.chunked(3).forEach { row ->
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    row.forEach { s ->
                        SelectChip(label = s, selected = sector == s, onClick = { sector = s }, modifier = Modifier.weight(1f))
                    }
                }
                Spacer(Modifier.height(8.dp))
            }
        }

        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            ProgressDots(count = 3, active = 2)
            val readyAlpha by animateFloatAsState(targetValue = if (ready) 1f else 0.45f, label = "ready")
            Box(modifier = Modifier.alpha(readyAlpha)) {
                PrimaryBtn(text = "Créer mon CV", onClick = onNext, enabled = ready)
            }
        }
    }
}

@Composable
private fun SelectChip(label: String, selected: Boolean, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val scale by animateFloatAsState(
        targetValue = if (selected) 1.04f else 1f,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium),
        label = "chip_scale"
    )

    Box(
        modifier = modifier
            .scale(scale)
            .clip(RoundedCornerShape(13.dp))
            .background(
                if (selected)
                    Brush.linearGradient(listOf(OBAccent.copy(0.22f), OBAccentCo.copy(0.14f)))
                else
                    Brush.linearGradient(listOf(OBCard, OBCard))
            )
            .border(
                1.dp,
                if (selected)
                    Brush.linearGradient(listOf(OBAccent.copy(0.85f), OBAccentCo.copy(0.55f)))
                else
                    Brush.linearGradient(listOf(OBInk.copy(0.14f), OBInk.copy(0.10f))),
                RoundedCornerShape(13.dp)
            )
            .clickable(onClick = onClick)
            .padding(12.dp),
        contentAlignment = Alignment.Center
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
            if (selected) {
                Box(
                    modifier = Modifier.size(18.dp).clip(CircleShape)
                        .background(Brush.linearGradient(listOf(OBAccent, OBAccentCo))),
                    contentAlignment = Alignment.Center
                ) {
                    Text("✓", color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.ExtraBold)
                }
                Spacer(Modifier.width(6.dp))
            }
            Text(
                label,
                fontSize = 13.sp,
                fontWeight = if (selected) FontWeight.SemiBold else FontWeight.Medium,
                color = if (selected) OBAccent else OBInk,
                textAlign = TextAlign.Center
            )
        }
    }
}

// ── Screen 5 · Success ───────────────────────────────────────
@Composable
private fun SuccessScreen(onComplete: () -> Unit, onRestart: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(28.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.SpaceBetween
    ) {
        Image(
            painter = painterResource(R.drawable.logo_icon),
            contentDescription = null,
            modifier = Modifier.size(72.dp).align(Alignment.Start),
            contentScale = ContentScale.Fit
        )

        Spacer(Modifier.weight(1f))

        val successPulse by rememberInfiniteTransition("s_pulse").animateFloat(
            0.12f, 0.38f,
            infiniteRepeatable(tween(1300, easing = FastOutSlowInEasing), RepeatMode.Reverse),
            label = "s_p"
        )
        Box(contentAlignment = Alignment.Center) {
            // Outer pulsing glow ring
            Box(
                modifier = Modifier.size(136.dp).clip(CircleShape)
                    .background(Brush.radialGradient(listOf(OBAccent.copy(successPulse), Color.Transparent)))
            )
            // Gradient checkmark circle
            Box(
                modifier = Modifier.size(96.dp).clip(CircleShape)
                    .background(Brush.linearGradient(listOf(OBAccent, Color(0xFF9B6AEE)))),
                contentAlignment = Alignment.Center
            ) {
                Text("✓", fontSize = 46.sp, color = Color.White, fontWeight = FontWeight.ExtraBold)
            }
        }

        Spacer(Modifier.height(30.dp))

        Text(
            "Tout est prêt.",
            fontSize = 30.sp,
            fontWeight = FontWeight.ExtraBold,
            color = OBInk,
            letterSpacing = (-0.5).sp
        )

        Spacer(Modifier.height(12.dp))

        Text(
            "Votre espace est configuré.\nL'IA vous attend pour écrire la suite.",
            fontSize = 20.sp,
            color = OBInk.copy(alpha = 0.7f),
            textAlign = TextAlign.Center,
            lineHeight = 28.sp,
            fontStyle = FontStyle.Italic,
            modifier = Modifier.padding(horizontal = 16.dp)
        )

        Spacer(Modifier.weight(1f))

        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            PrimaryBtn(text = "Entrer dans l'éditeur", onClick = onComplete)
            GhostBtn(text = "Revoir l'introduction", onClick = onRestart)
        }
    }
}
