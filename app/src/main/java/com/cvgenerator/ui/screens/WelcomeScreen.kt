package com.cvgenerator.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.Image
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import com.cvgenerator.R
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.ui.anim.*
import com.cvgenerator.ui.theme.*
import kotlinx.coroutines.delay

private val WBg      = Color(0xFF0D0920)
private val WBgMid   = Color(0xFF180C30)
private val WInk     = Color(0xFFEFEBFF)
private val WInkSub  = Color(0xFFBBB0D8)
private val WAccent  = Accent

@Composable
fun WelcomeScreen(onGetStarted: () -> Unit, onLogin: () -> Unit) {
    val words = listOf("remarquer", "recruter", "choisir", "embaucher")
    var wordIndex by remember { mutableStateOf(0) }

    var targetScore by remember { mutableStateOf(0) }
    val animScore by animateIntAsState(targetScore, tween(1600, easing = FastOutSlowInEasing), label = "score")
    val barFraction by animateFloatAsState(targetScore / 100f, tween(1600, easing = FastOutSlowInEasing), label = "bar")

    val vis = rememberStaggerVisible(8, startDelay = 100L, stepDelay = 85L)

    LaunchedEffect(Unit) {
        delay(350); targetScore = 94
        while (true) { delay(2800); wordIndex = (wordIndex + 1) % words.size }
    }

    val blobs = rememberInfiniteTransition(label = "blobs")
    val b1x by blobs.animateFloat(0f, 55f, infiniteRepeatable(tween(7000, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "b1x")
    val b1y by blobs.animateFloat(0f, 35f, infiniteRepeatable(tween(9000, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "b1y")
    val b2x by blobs.animateFloat(0f, -70f, infiniteRepeatable(tween(8500, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "b2x")
    val b2y by blobs.animateFloat(0f, 55f, infiniteRepeatable(tween(6200, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "b2y")
    val b3x by blobs.animateFloat(0f, 40f, infiniteRepeatable(tween(10500, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "b3x")
    val b3y by blobs.animateFloat(0f, -30f, infiniteRepeatable(tween(7800, easing = FastOutSlowInEasing), RepeatMode.Reverse), label = "b3y")

    val floatY  = rememberFloatOffset(amplitude = 6f, periodMs = 3000)
    val glowPulse = rememberPulseAlpha(min = 0.10f, max = 0.30f, durationMs = 1800)

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(WBg, WBgMid, WBg)))
    ) {
        // Animated gradient blobs
        Canvas(modifier = Modifier.fillMaxSize()) {
            drawCircle(
                brush = Brush.radialGradient(
                    listOf(WAccent.copy(alpha = 0.42f), Color.Transparent),
                    center = Offset(size.width * 0.55f + b1x, -80f + b1y),
                    radius = size.width * 0.82f
                ), radius = size.width * 0.82f,
                center = Offset(size.width * 0.55f + b1x, -80f + b1y)
            )
            drawCircle(
                brush = Brush.radialGradient(
                    listOf(AccentCo.copy(alpha = 0.24f), Color.Transparent),
                    center = Offset(size.width * 0.90f + b2x, size.height * 0.52f + b2y),
                    radius = size.width * 0.62f
                ), radius = size.width * 0.62f,
                center = Offset(size.width * 0.90f + b2x, size.height * 0.52f + b2y)
            )
            drawCircle(
                brush = Brush.radialGradient(
                    listOf(AmethysteAccent.copy(alpha = 0.18f), Color.Transparent),
                    center = Offset(size.width * 0.12f + b3x, size.height * 0.78f + b3y),
                    radius = size.width * 0.50f
                ), radius = size.width * 0.50f,
                center = Offset(size.width * 0.12f + b3x, size.height * 0.78f + b3y)
            )
        }

        Column(
            modifier = Modifier.fillMaxSize().padding(horizontal = 24.dp),
            verticalArrangement = Arrangement.SpaceBetween
        ) {
            // ── Top bar ────────────────────────────────────────────
            EntranceItem(visible = vis[0], fromY = -22f) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(top = 56.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Image(
                        painter = painterResource(R.drawable.logo_icon),
                        contentDescription = "CV Generator",
                        modifier = Modifier.size(52.dp),
                        contentScale = ContentScale.Fit
                    )
                    LoginPill(onClick = onLogin)
                }
            }

            // ── Hero text block ────────────────────────────────────
            Column {
                EntranceItem(visible = vis[1], fromY = 18f, fromScale = 0.90f) {
                    GradientBadge("✦  GÉNÉRATEUR DE CV · IA")
                }
                Spacer(Modifier.height(14.dp))
                EntranceItem(visible = vis[2], fromY = 28f) {
                    Text("Le CV qui", fontSize = 43.sp, fontWeight = FontWeight.ExtraBold,
                        color = WInk, letterSpacing = (-1.5).sp, lineHeight = 50.sp)
                }
                EntranceItem(visible = vis[3], fromY = 28f) {
                    Text("vous fait", fontSize = 43.sp, fontWeight = FontWeight.ExtraBold,
                        color = WInk, letterSpacing = (-1.5).sp, lineHeight = 50.sp)
                }
                EntranceItem(visible = vis[4], fromY = 28f) {
                    AnimatedContent(
                        targetState = wordIndex,
                        transitionSpec = {
                            (fadeIn(tween(220)) +
                             scaleIn(tween(240, easing = FastOutSlowInEasing), 0.78f) +
                             slideInVertically(tween(240, easing = FastOutSlowInEasing)) { it / 3 })
                            .togetherWith(
                                fadeOut(tween(160)) +
                                scaleOut(tween(160), 0.78f) +
                                slideOutVertically(tween(160)) { -it / 3 }
                            )
                        }, label = "word"
                    ) { idx ->
                        Text(
                            words[idx] + ".",
                            style = TextStyle(
                                brush = Brush.linearGradient(listOf(WAccent, AccentCo)),
                                fontSize = 43.sp, fontWeight = FontWeight.ExtraBold,
                                letterSpacing = (-1.5).sp, lineHeight = 50.sp
                            )
                        )
                    }
                }
                Spacer(Modifier.height(16.dp))
                EntranceItem(visible = vis[5], fromY = 16f) {
                    Text(
                        "Décrivez votre parcours. L'IA le transforme en CV qui décroche des entretiens.",
                        fontSize = 16.sp, color = WInkSub, lineHeight = 25.sp
                    )
                }
            }

            // ── Floating hero card ─────────────────────────────────
            EntranceItem(visible = vis[6], fromY = 38f, fromScale = 0.86f) {
                Box(modifier = Modifier.fillMaxWidth().offset(y = floatY), contentAlignment = Alignment.Center) {
                    // Ambient glow behind card
                    Box(
                        modifier = Modifier.size(300.dp, 130.dp)
                            .background(Brush.radialGradient(listOf(WAccent.copy(glowPulse), Color.Transparent)))
                    )
                    HeroCard(score = animScore, barFraction = barFraction)
                }
            }

            // ── Social proof ───────────────────────────────────────
            EntranceItem(visible = vis[6], fromY = 14f) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.padding(bottom = 4.dp)
                ) {
                    OverlappingAvatars()
                    Column {
                        Text("★★★★★", color = WAccent, fontSize = 12.sp)
                        Text("Rejoint par 12 000+ candidats", color = WInkSub, fontSize = 11.5.sp)
                    }
                }
            }

            // ── CTA buttons ────────────────────────────────────────
            EntranceItem(visible = vis[7], fromY = 30f, fromScale = 0.94f) {
                Column(
                    modifier = Modifier.padding(bottom = 36.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    GradientPressButton(
                        onClick = onGetStarted,
                        modifier = Modifier.fillMaxWidth().height(58.dp)
                    ) {
                        Text("Créer mon CV — gratuit  →", fontSize = 16.5.sp,
                            fontWeight = FontWeight.Bold, color = Color.White)
                    }
                    GhostPressButton(
                        onClick = onLogin,
                        modifier = Modifier.fillMaxWidth().height(50.dp)
                    ) {
                        Text("Voir un exemple en 30 s", fontSize = 14.5.sp,
                            fontWeight = FontWeight.SemiBold, color = WInk.copy(alpha = 0.72f))
                    }
                }
            }
        }
    }
}

// ── Private UI atoms ──────────────────────────────────────────────────────────

@Composable
private fun GradientBadge(text: String) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(12.dp))
            .background(Brush.linearGradient(listOf(WAccent.copy(0.28f), AccentCo.copy(0.15f))))
            .border(1.dp, WAccent.copy(alpha = 0.42f), RoundedCornerShape(12.dp))
            .padding(horizontal = 12.dp, vertical = 5.dp)
    ) {
        Text(text, color = AccentCo, fontSize = 10.sp, letterSpacing = 2.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun LoginPill(onClick: () -> Unit) {
    val src = remember { MutableInteractionSource() }
    val pressed by src.collectIsPressedAsState()
    val sc by animateFloatAsState(if (pressed) 0.94f else 1f, spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "pill")
    Box(
        modifier = Modifier
            .scale(sc)
            .clip(RoundedCornerShape(20.dp))
            .border(1.dp, WInk.copy(alpha = 0.24f), RoundedCornerShape(20.dp))
            .clickable(interactionSource = src, indication = null, onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Text("Connexion", color = WInk.copy(alpha = 0.82f), fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
    }
}

@Composable
private fun GradientPressButton(
    onClick: () -> Unit, modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    val src = remember { MutableInteractionSource() }
    val pressed by src.collectIsPressedAsState()
    val sc by animateFloatAsState(if (pressed) 0.965f else 1f, spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "gbtn")
    Box(
        modifier = modifier.scale(sc).clip(RoundedCornerShape(18.dp))
            .background(Brush.linearGradient(listOf(WAccent, Color(0xFF9B6AEE))))
            .clickable(interactionSource = src, indication = null, onClick = onClick),
        contentAlignment = Alignment.Center, content = content
    )
}

@Composable
private fun GhostPressButton(
    onClick: () -> Unit, modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    val src = remember { MutableInteractionSource() }
    val pressed by src.collectIsPressedAsState()
    val sc by animateFloatAsState(if (pressed) 0.97f else 1f, spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "ghost")
    Box(
        modifier = modifier.scale(sc).clip(RoundedCornerShape(18.dp))
            .border(1.dp, WInk.copy(alpha = 0.22f), RoundedCornerShape(18.dp))
            .clickable(interactionSource = src, indication = null, onClick = onClick),
        contentAlignment = Alignment.Center, content = content
    )
}

// ── Hero card — glassmorphism on dark bg ──────────────────────────────────────

@Composable
private fun HeroCard(score: Int, barFraction: Float) {
    Box(
        modifier = Modifier
            .width(296.dp)
            .clip(RoundedCornerShape(28.dp))
            .background(Color.White.copy(alpha = 0.07f))
            .border(
                1.dp,
                Brush.linearGradient(listOf(Color.White.copy(0.28f), Color.White.copy(0.06f), WAccent.copy(0.22f))),
                RoundedCornerShape(28.dp)
            )
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                // Mini CV thumbnail
                Surface(
                    modifier = Modifier.size(52.dp, 68.dp), shape = RoundedCornerShape(10.dp),
                    color = Color.White.copy(alpha = 0.10f)
                ) {
                    Column(modifier = Modifier.padding(7.dp)) {
                        Text("Amina D.", fontSize = 7.sp, fontWeight = FontWeight.SemiBold, color = WInk, lineHeight = 8.sp)
                        Spacer(Modifier.height(4.dp))
                        HorizontalDivider(color = WInk.copy(alpha = 0.15f), thickness = 0.5.dp)
                        Spacer(Modifier.height(4.dp))
                        listOf(0.85f to true, 0.62f to false, 0.74f to false).forEach { (w, bold) ->
                            Box(modifier = Modifier.fillMaxWidth(w).height(2.5.dp).clip(RoundedCornerShape(2.dp))
                                .background(if (bold) WAccent.copy(0.90f) else WInk.copy(0.16f)))
                            Spacer(Modifier.height(2.5.dp))
                        }
                    }
                }
                Column(modifier = Modifier.weight(1f)) {
                    Text("Score ATS", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = WInk)
                    Text("Optimisé à l'instant", fontSize = 11.sp, color = WInkSub.copy(0.65f))
                    Spacer(Modifier.height(10.dp))
                    Box(modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(4.dp))
                        .background(WInk.copy(0.10f))) {
                        Box(modifier = Modifier.fillMaxWidth(barFraction).fillMaxHeight()
                            .clip(RoundedCornerShape(4.dp))
                            .background(Brush.linearGradient(listOf(WAccent, AccentCo))))
                    }
                }
                Text(
                    "$score",
                    style = TextStyle(
                        brush = Brush.linearGradient(listOf(WAccent, AccentCo)),
                        fontSize = 30.sp, fontWeight = FontWeight.ExtraBold
                    )
                )
            }
            Spacer(Modifier.height(16.dp))
            // AI chip — gradient border glass
            Box(
                modifier = Modifier.fillMaxWidth().clip(RoundedCornerShape(14.dp))
                    .background(Brush.linearGradient(listOf(WAccent.copy(0.18f), AccentCo.copy(0.10f))))
                    .border(
                        1.dp,
                        Brush.linearGradient(listOf(WAccent.copy(0.52f), AccentCo.copy(0.28f))),
                        RoundedCornerShape(14.dp)
                    )
            ) {
                Row(modifier = Modifier.padding(horizontal = 12.dp, vertical = 11.dp),
                    verticalAlignment = Alignment.Top, horizontalArrangement = Arrangement.spacedBy(9.dp)) {
                    Box(modifier = Modifier.size(20.dp).clip(CircleShape)
                        .background(Brush.linearGradient(listOf(WAccent, AccentCo))),
                        contentAlignment = Alignment.Center) {
                        Text("✦", fontSize = 10.sp, color = Color.White, fontWeight = FontWeight.ExtraBold)
                    }
                    Text("Piloté une équipe de 6 et accru le CA de 32 %.",
                        fontSize = 11.5.sp, color = WInk.copy(0.85f), lineHeight = 16.sp,
                        fontWeight = FontWeight.Medium)
                }
            }
        }
    }
}

// ── Overlapping avatars ───────────────────────────────────────────────────────

@Composable
private fun OverlappingAvatars() {
    val colors  = listOf(Accent, AccentCo, AmethysteAccent, IndigoAccent)
    val initials = listOf("A", "M", "K", "S")
    Box(modifier = Modifier.width(82.dp).height(28.dp)) {
        colors.forEachIndexed { i, color ->
            Box(
                modifier = Modifier.offset(x = (i * 18).dp).size(28.dp).clip(CircleShape)
                    .border(2.dp, WBg, CircleShape)
                    .background(Brush.linearGradient(listOf(color, color.copy(alpha = 0.55f)))),
                contentAlignment = Alignment.Center
            ) {
                Text(initials[i], fontSize = 10.sp, fontWeight = FontWeight.ExtraBold, color = Color.White)
            }
        }
    }
}
