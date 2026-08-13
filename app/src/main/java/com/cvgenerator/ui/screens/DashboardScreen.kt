package com.cvgenerator.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.*
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.R
import com.cvgenerator.ui.anim.*
import com.cvgenerator.ui.theme.*
import kotlinx.coroutines.delay

private val DBg     = Color(0xFFF1ECFB)
private val DInk    = Color(0xFF1C1626)
private val DCard   = Color(0xFFFFFFFF)
private val DAccent = Accent
private val DDark   = Color(0xFF0D0920)
private val DDarkMid = Color(0xFF180C30)
private val DWhite  = Color(0xFFEFEBFF)

data class CvItem(
    val id: Int, val title: String, val role: String,
    val edited: String, val score: Int, val isDraft: Boolean = false
)

private val sampleCvs = listOf(
    CvItem(1, "CV Senior Dev",   "Développeur Full-Stack",   "Il y a 2h",  92),
    CvItem(2, "CV UX/Produit",   "Product Designer",          "Hier",       78, isDraft = true),
    CvItem(3, "CV Tech Lead",    "Engineering Manager",       "Il y a 3j",  85)
)

@Composable
fun DashboardScreen(
    onOpenEditor: (Int) -> Unit,
    onCreateNew: () -> Unit,
    onProfile: () -> Unit
) {
    var activeFilter by remember { mutableStateOf("Tous") }
    val filters = listOf("Tous", "Finalisés", "Brouillons")
    var activeTab by remember { mutableStateOf(0) }

    var statsVisible by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { delay(300); statsVisible = true }
    val stat1 by animateIntAsState(if (statsVisible) 3 else 0, tween(700, easing = FastOutSlowInEasing), label = "s1")
    val stat2 by animateIntAsState(if (statsVisible) 92 else 0, tween(1200, easing = FastOutSlowInEasing), label = "s2")
    val stat3 by animateIntAsState(if (statsVisible) 1 else 0, tween(500, easing = FastOutSlowInEasing), label = "s3")

    val vis = rememberStaggerVisible(3, startDelay = 80L, stepDelay = 100L)

    val filtered = when (activeFilter) {
        "Finalisés"  -> sampleCvs.filter { !it.isDraft }
        "Brouillons" -> sampleCvs.filter { it.isDraft }
        else -> sampleCvs
    }

    Box(modifier = Modifier.fillMaxSize().background(DBg)) {
        Column(modifier = Modifier.fillMaxSize()) {

            // ── Dark gradient header ───────────────────────────────
            EntranceItem(visible = vis[0], fromY = -28f) {
                Box(
                    modifier = Modifier.fillMaxWidth()
                        .background(
                            Brush.verticalGradient(listOf(DDark, DDarkMid, DDark.copy(alpha = 0f)))
                        )
                ) {
                    Column(modifier = Modifier.padding(horizontal = 20.dp).padding(top = 52.dp, bottom = 24.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Image(
                                    painter = painterResource(R.drawable.logo_icon),
                                    contentDescription = "CV Generator",
                                    modifier = Modifier.size(28.dp),
                                    contentScale = ContentScale.Fit
                                )
                                Spacer(Modifier.height(6.dp))
                                Text("Bonjour 👋", fontSize = 13.sp, color = DWhite.copy(alpha = 0.55f))
                                Text("Amina Diallo", fontSize = 22.sp, fontWeight = FontWeight.ExtraBold, color = DWhite)
                            }
                            // Avatar with press scale
                            val avatarSrc = remember { MutableInteractionSource() }
                            val avatarPressed by avatarSrc.collectIsPressedAsState()
                            val avatarScale by animateFloatAsState(
                                if (avatarPressed) 0.92f else 1f,
                                spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "av_s"
                            )
                            Box(
                                modifier = Modifier.size(44.dp).scale(avatarScale).clip(CircleShape)
                                    .background(Brush.linearGradient(listOf(DAccent, AccentCo)))
                                    .border(2.dp, DWhite.copy(0.20f), CircleShape)
                                    .clickable(interactionSource = avatarSrc, indication = null) { onProfile() },
                                contentAlignment = Alignment.Center
                            ) {
                                Text("AD", fontSize = 13.sp, fontWeight = FontWeight.ExtraBold, color = Color.White)
                            }
                        }

                        Spacer(Modifier.height(20.dp))

                        // Stats strip — dark glass style
                        Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                            DarkStatChip("$stat1", "CV actifs", modifier = Modifier.weight(1f))
                            DarkStatChip("$stat2", "Meilleur score", highlight = true, modifier = Modifier.weight(1f))
                            DarkStatChip("$stat3", "Brouillon", modifier = Modifier.weight(1f))
                        }
                    }
                }
            }

            // ── Filter chips ──────────────────────────────────────
            EntranceItem(visible = vis[1], fromY = 14f) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp, vertical = 14.dp),
                    horizontalArrangement = Arrangement.spacedBy(9.dp)
                ) {
                    filters.forEach { f ->
                        val active = f == activeFilter
                        val chipScale by animateFloatAsState(
                            if (active) 1.04f else 1f,
                            spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium), label = "fc_$f"
                        )
                        Box(
                            modifier = Modifier.scale(chipScale)
                                .clip(RoundedCornerShape(20.dp))
                                .background(
                                    if (active) Brush.linearGradient(listOf(DAccent, AccentCo.copy(0.8f)))
                                    else Brush.linearGradient(listOf(DCard, DCard))
                                )
                                .border(1.dp, if (active) Color.Transparent else DInk.copy(0.10f), RoundedCornerShape(20.dp))
                                .clickable { activeFilter = f }
                                .padding(horizontal = 14.dp, vertical = 7.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(f, fontSize = 13.sp,
                                fontWeight = if (active) FontWeight.Bold else FontWeight.Normal,
                                color = if (active) Color.White else DInk.copy(0.60f))
                        }
                    }
                }
            }

            // ── CV list with stagger ──────────────────────────────
            EntranceItem(visible = vis[2], fromY = 20f) {
                LazyColumn(
                    contentPadding = PaddingValues(horizontal = 20.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    itemsIndexed(filtered) { index, cv ->
                        StaggeredCvCard(index = index, cv = cv, onClick = { onOpenEditor(cv.id) })
                    }
                    item {
                        Spacer(Modifier.height(4.dp))
                        CreateNewCard(onClick = onCreateNew)
                        Spacer(Modifier.height(100.dp))
                    }
                }
            }
        }

        // ── Glass bottom tab bar ──────────────────────────────────
        BottomTabBar(
            activeTab = activeTab,
            onTabChange = { activeTab = it },
            onCreateNew = onCreateNew,
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

// ── Dark stat chip (for dark header) ─────────────────────────────────────────

@Composable
private fun DarkStatChip(value: String, label: String, highlight: Boolean = false, modifier: Modifier = Modifier) {
    Box(
        modifier = modifier
            .clip(RoundedCornerShape(14.dp))
            .background(
                if (highlight) Brush.linearGradient(listOf(DAccent, Color(0xFF9B6AEE)))
                else Brush.linearGradient(listOf(Color.White.copy(0.10f), Color.White.copy(0.06f)))
            )
            .border(1.dp, if (highlight) Color.Transparent else Color.White.copy(0.14f), RoundedCornerShape(14.dp))
            .padding(horizontal = 10.dp, vertical = 10.dp),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(value, fontSize = 20.sp, fontWeight = FontWeight.ExtraBold, color = Color.White)
            Text(label, fontSize = 10.sp, color = Color.White.copy(0.65f), fontWeight = FontWeight.Medium)
        }
    }
}

// ── Staggered CV card ─────────────────────────────────────────────────────────

@Composable
private fun StaggeredCvCard(index: Int, cv: CvItem, onClick: () -> Unit) {
    var visible by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { delay(200L + index * 100L); visible = true }
    EntranceItem(visible = visible, fromY = 32f, fromScale = 0.94f) {
        CvCard(cv = cv, onClick = onClick)
    }
}

@Composable
private fun CvCard(cv: CvItem, onClick: () -> Unit) {
    val src = remember { MutableInteractionSource() }
    val pressed by src.collectIsPressedAsState()
    val scale by animateFloatAsState(
        if (pressed) 0.975f else 1f,
        spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "card_s"
    )
    Surface(
        modifier = Modifier.fillMaxWidth().scale(scale),
        shape = RoundedCornerShape(18.dp),
        color = DCard,
        shadowElevation = if (pressed) 2.dp else 8.dp
    ) {
        Row(
            modifier = Modifier.padding(14.dp).clickable(src, null) { onClick() },
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // Mini CV thumbnail with gradient accent line
            Surface(
                modifier = Modifier.size(52.dp, 70.dp),
                shape = RoundedCornerShape(9.dp),
                color = DBg, shadowElevation = 4.dp
            ) {
                Column(modifier = Modifier.padding(7.dp)) {
                    Box(modifier = Modifier.fillMaxWidth(0.7f).height(5.dp)
                        .clip(RoundedCornerShape(3.dp))
                        .background(Brush.linearGradient(listOf(DAccent, AccentCo))))
                    Spacer(Modifier.height(5.dp))
                    HorizontalDivider(color = DInk.copy(alpha = 0.10f), thickness = 0.5.dp)
                    Spacer(Modifier.height(5.dp))
                    listOf(0.9f, 0.7f, 0.8f, 0.6f, 0.75f).forEach { w ->
                        Box(modifier = Modifier.fillMaxWidth(w).height(2.dp)
                            .clip(RoundedCornerShape(2.dp)).background(DInk.copy(alpha = 0.12f)))
                        Spacer(Modifier.height(2.5.dp))
                    }
                }
            }

            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(7.dp)) {
                    Text(cv.title, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = DInk)
                    if (cv.isDraft) {
                        Box(
                            modifier = Modifier.clip(RoundedCornerShape(6.dp))
                                .background(Brush.linearGradient(listOf(DAccent.copy(0.12f), AccentCo.copy(0.08f))))
                                .border(1.dp, DAccent.copy(0.28f), RoundedCornerShape(6.dp))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text("Brouillon", fontSize = 9.sp, color = DAccent, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }
                Text(cv.role, fontSize = 12.sp, color = DInk.copy(alpha = 0.52f),
                    maxLines = 1, overflow = TextOverflow.Ellipsis)
                Text(cv.edited, fontSize = 11.sp, color = DInk.copy(alpha = 0.32f))
            }

            ScoreRingSmall(score = cv.score)
        }
    }
}

// ── Score ring with sweep gradient ───────────────────────────────────────────

@Composable
fun ScoreRingSmall(score: Int, size: Float = 46f) {
    var started by remember { mutableStateOf(false) }
    val animScore by animateIntAsState(
        if (started) score else 0, tween(1000, easing = FastOutSlowInEasing), label = "ring_score"
    )
    val sweep = animScore / 100f * 360f
    val glowAlpha = rememberPulseAlpha(0.12f, 0.38f, 1600)
    LaunchedEffect(Unit) { started = true }

    Box(modifier = Modifier.size(size.dp), contentAlignment = Alignment.Center) {
        androidx.compose.foundation.Canvas(modifier = Modifier.fillMaxSize()) {
            val stroke = Stroke(width = 4.dp.toPx(), cap = StrokeCap.Round)
            // Outer glow arc
            drawArc(color = DAccent.copy(alpha = glowAlpha),
                startAngle = -90f, sweepAngle = sweep, useCenter = false,
                style = Stroke(width = 9.dp.toPx(), cap = StrokeCap.Round))
            // Track
            drawArc(color = DInk.copy(alpha = 0.08f),
                startAngle = -90f, sweepAngle = 360f, useCenter = false, style = stroke)
            // Sweep gradient arc
            drawArc(
                brush = Brush.sweepGradient(listOf(DAccent, AccentCo, DAccent), center = this.center),
                startAngle = -90f, sweepAngle = sweep, useCenter = false, style = stroke
            )
        }
        Text(
            "$animScore",
            style = TextStyle(
                brush = Brush.linearGradient(listOf(DAccent, AccentCo)),
                fontSize = (size * 0.25f).sp, fontWeight = FontWeight.ExtraBold
            )
        )
    }
}

// ── Create new card ───────────────────────────────────────────────────────────

@Composable
private fun CreateNewCard(onClick: () -> Unit) {
    val src = remember { MutableInteractionSource() }
    val pressed by src.collectIsPressedAsState()
    val scale by animateFloatAsState(
        if (pressed) 0.97f else 1f,
        spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "new_s"
    )
    Box(
        modifier = Modifier.fillMaxWidth().height(76.dp).scale(scale)
            .clip(RoundedCornerShape(18.dp))
            .background(Brush.linearGradient(listOf(DAccent.copy(0.06f), AccentCo.copy(0.04f))))
            .border(
                2.dp,
                Brush.linearGradient(listOf(DAccent.copy(0.45f), AccentCo.copy(0.30f))),
                RoundedCornerShape(18.dp)
            )
            .clickable(src, null) { onClick() },
        contentAlignment = Alignment.Center
    ) {
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            Box(
                modifier = Modifier.size(36.dp).clip(CircleShape)
                    .background(Brush.linearGradient(listOf(DAccent, AccentCo))),
                contentAlignment = Alignment.Center
            ) {
                Text("+", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White)
            }
            Text("Créer un nouveau CV", fontSize = 15.sp, fontWeight = FontWeight.SemiBold,
                color = DAccent)
        }
    }
}

// ── Glass bottom tab bar ──────────────────────────────────────────────────────

@Composable
private fun BottomTabBar(
    activeTab: Int, onTabChange: (Int) -> Unit,
    onCreateNew: () -> Unit, modifier: Modifier = Modifier
) {
    val fabPulse = rememberPulseAlpha(0f, 0.32f, 1400)

    Surface(
        modifier = modifier.fillMaxWidth(),
        color = DCard.copy(alpha = 0.97f),
        shadowElevation = 24.dp
    ) {
        Box(modifier = Modifier.fillMaxWidth()) {
            // Top gradient separator line
            Box(
                modifier = Modifier.fillMaxWidth().height(1.dp)
                    .background(Brush.horizontalGradient(listOf(Color.Transparent, DAccent.copy(0.28f), Color.Transparent)))
            )
            Row(
                modifier = Modifier.fillMaxWidth().height(72.dp).padding(bottom = 8.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                val tabs = listOf("⌂" to "Accueil", "⊟" to "Modèles", null, "✦" to "IA", "◯" to "Profil")
                tabs.forEachIndexed { i, tab ->
                    if (tab == null) {
                        Box(modifier = Modifier.weight(1f), contentAlignment = Alignment.Center) {
                            // Pulse ring
                            androidx.compose.foundation.Canvas(modifier = Modifier.size(66.dp)) {
                                drawCircle(color = DAccent.copy(alpha = fabPulse), radius = size.minDimension / 2)
                            }
                            val fabSrc = remember { MutableInteractionSource() }
                            val fabPressed by fabSrc.collectIsPressedAsState()
                            val fabScale by animateFloatAsState(
                                if (fabPressed) 0.88f else 1f,
                                spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "fab_s"
                            )
                            Box(
                                modifier = Modifier.size(52.dp).scale(fabScale).clip(CircleShape)
                                    .background(Brush.linearGradient(listOf(DAccent, AccentCo)))
                                    .clickable(fabSrc, null) { onCreateNew() },
                                contentAlignment = Alignment.Center
                            ) {
                                Text("+", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Color.White)
                            }
                        }
                    } else {
                        val tabIdx = if (i > 2) i - 1 else i
                        val active = tabIdx == activeTab
                        val iconScale by animateFloatAsState(
                            if (active) 1.18f else 1f,
                            spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMediumLow), label = "tab_s_$tabIdx"
                        )
                        val labelAlpha by animateFloatAsState(
                            if (active) 1f else 0.38f, tween(200), label = "tab_l_$tabIdx"
                        )
                        Column(
                            modifier = Modifier.weight(1f).clickable { onTabChange(tabIdx) },
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Text(tab.first,
                                fontSize = if (active) 20.sp else 18.sp,
                                color = if (active) DAccent else DInk.copy(alpha = 0.35f),
                                modifier = Modifier.scale(iconScale))
                            Text(tab.second, fontSize = 10.sp,
                                color = if (active) DAccent else DInk.copy(alpha = 0.35f),
                                fontWeight = if (active) FontWeight.SemiBold else FontWeight.Normal,
                                modifier = Modifier.alpha(labelAlpha))
                            Spacer(Modifier.height(2.dp))
                            // Gradient active indicator pill
                            val dotScale by animateFloatAsState(
                                if (active) 1f else 0f,
                                spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "dot_$tabIdx"
                            )
                            Box(
                                modifier = Modifier.scale(dotScale).width(16.dp).height(3.dp)
                                    .clip(RoundedCornerShape(2.dp))
                                    .background(Brush.linearGradient(listOf(DAccent, AccentCo)))
                            )
                        }
                    }
                }
            }
        }
    }
}
