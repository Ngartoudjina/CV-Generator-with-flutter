@file:OptIn(ExperimentalLayoutApi::class)

package com.cvgenerator.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.R
import com.cvgenerator.ui.anim.*
import com.cvgenerator.ui.theme.*
import kotlinx.coroutines.delay

private val EBg      = Color(0xFFF1ECFB)
private val EInk     = Color(0xFF1C1626)
private val ECard    = Color(0xFFFFFFFF)
private val EAccent  = Accent
private val EDark    = Color(0xFF0D0920)
private val EDarkMid = Color(0xFF180C30)
private val EWhite   = Color(0xFFEFEBFF)

enum class AiState { IDLE, THINKING, DONE }

@Composable
fun EditorScreen(cvId: Int = 1, onBack: () -> Unit, onExport: () -> Unit) {
    var isPreview by remember { mutableStateOf(false) }
    var expandedSection by remember { mutableStateOf("Profil") }
    var aiState by remember { mutableStateOf(AiState.IDLE) }

    val sections = listOf("Profil", "Expérience", "Compétences", "Formation")
    var skills by remember { mutableStateOf(listOf("Kotlin", "Android", "Jetpack Compose", "Firebase")) }
    val suggestions = listOf("React Native", "Flutter", "iOS", "CI/CD", "Figma")
    var showSuggestions by remember { mutableStateOf(false) }

    var profileName    by remember { mutableStateOf("Amina Diallo") }
    var profileTitle   by remember { mutableStateOf("Développeuse Full-Stack") }
    var profileSummary by remember { mutableStateOf("Développeuse passionnée avec 5 ans d'expérience dans la création d'applications mobiles et web à fort impact.") }

    // AI THINKING dots
    val aiInf = rememberInfiniteTransition(label = "ai_inf")
    val dot1 by aiInf.animateFloat(0.3f, 1f, infiniteRepeatable(tween(380), RepeatMode.Reverse), label = "d1")
    val dot2 by aiInf.animateFloat(0.3f, 1f, infiniteRepeatable(tween(380, delayMillis = 130), RepeatMode.Reverse), label = "d2")
    val dot3 by aiInf.animateFloat(0.3f, 1f, infiniteRepeatable(tween(380, delayMillis = 260), RepeatMode.Reverse), label = "d3")

    // Shimmer for AI thinking button
    val aiShimmer = rememberShimmerBrush(Color.White.copy(alpha = 0.55f), 240f)

    // Header entrance
    val vis = rememberStaggerVisible(3, startDelay = 60L, stepDelay = 80L)

    // Export bar slide up
    var exportVisible by remember { mutableStateOf(false) }
    LaunchedEffect(Unit) { delay(350); exportVisible = true }
    val exportY by animateDpAsState(
        if (exportVisible) 0.dp else 80.dp,
        spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMediumLow),
        label = "export_y"
    )

    Box(modifier = Modifier.fillMaxSize().background(EBg)) {
        Column(modifier = Modifier.fillMaxSize()) {

            // ── Dark gradient header ───────────────────────────────
            EntranceItem(visible = vis[0], fromY = -20f) {
                Box(
                    modifier = Modifier.fillMaxWidth()
                        .background(Brush.verticalGradient(listOf(EDark, EDarkMid, EDark.copy(alpha = 0f))))
                ) {
                    Column(modifier = Modifier.padding(top = 48.dp, bottom = 8.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            val backSrc = remember { MutableInteractionSource() }
                            val backPressed by backSrc.collectIsPressedAsState()
                            val backScale by animateFloatAsState(
                                if (backPressed) 0.86f else 1f,
                                spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "back_s"
                            )
                            Box(
                                modifier = Modifier.size(36.dp).scale(backScale)
                                    .clip(RoundedCornerShape(10.dp))
                                    .background(EWhite.copy(alpha = 0.12f))
                                    .border(1.dp, EWhite.copy(alpha = 0.18f), RoundedCornerShape(10.dp))
                                    .clickable(interactionSource = backSrc, indication = null, onClick = onBack),
                                contentAlignment = Alignment.Center
                            ) {
                                Text("←", fontSize = 18.sp, color = EWhite)
                            }
                            Row(
                                modifier = Modifier.weight(1f).padding(horizontal = 10.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(8.dp)
                            ) {
                                Image(
                                    painter = painterResource(R.drawable.logo_icon),
                                    contentDescription = null,
                                    modifier = Modifier.size(24.dp),
                                    contentScale = ContentScale.Fit
                                )
                                Text("CV Senior Dev", fontSize = 16.sp, fontWeight = FontWeight.Bold,
                                    color = EWhite)
                            }
                            ScoreRingSmall(score = 92, size = 40f)
                        }

                        // Edit / Preview toggle — dark glass style
                        EntranceItem(visible = vis[1], fromY = 12f) {
                            Row(
                                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 6.dp),
                                horizontalArrangement = Arrangement.Center
                            ) {
                                Box(
                                    modifier = Modifier.clip(RoundedCornerShape(12.dp))
                                        .background(EWhite.copy(alpha = 0.10f))
                                        .border(1.dp, EWhite.copy(alpha = 0.15f), RoundedCornerShape(12.dp))
                                ) {
                                    Row(modifier = Modifier.padding(4.dp)) {
                                        listOf("Éditer" to false, "Aperçu" to true).forEach { (label, isP) ->
                                            val active = isP == isPreview
                                            val tabScale by animateFloatAsState(
                                                if (active) 1f else 0.96f,
                                                spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium),
                                                label = "tab_s_$label"
                                            )
                                            Box(
                                                modifier = Modifier.clip(RoundedCornerShape(9.dp))
                                                    .scale(tabScale)
                                                    .background(
                                                        if (active)
                                                            Brush.linearGradient(listOf(EAccent, Color(0xFF9B6AEE)))
                                                        else
                                                            Brush.linearGradient(listOf(Color.Transparent, Color.Transparent))
                                                    )
                                                    .clickable { isPreview = isP }
                                            ) {
                                                Text(label,
                                                    modifier = Modifier.padding(horizontal = 28.dp, vertical = 9.dp),
                                                    fontSize = 13.sp,
                                                    fontWeight = if (active) FontWeight.Bold else FontWeight.Normal,
                                                    color = if (active) Color.White else EWhite.copy(alpha = 0.45f))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Spacer(Modifier.height(8.dp))
                    }
                }
            }

            // ── Content ───────────────────────────────────────────
            EntranceItem(visible = vis[2], fromY = 20f) {
                if (isPreview) {
                    Column(
                        modifier = Modifier.weight(1f).verticalScroll(rememberScrollState()).padding(20.dp)
                    ) {
                        PreviewPanel(profileName, profileTitle, profileSummary, skills)
                    }
                } else {
                    Column(
                        modifier = Modifier.weight(1f).verticalScroll(rememberScrollState())
                            .padding(horizontal = 16.dp, vertical = 12.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        sections.forEach { section ->
                            AccordionSection(
                                title = section,
                                expanded = section == expandedSection,
                                onToggle = { expandedSection = if (expandedSection == section) "" else section }
                            ) {
                                when (section) {
                                    "Profil" -> ProfilContent(
                                        profileName, profileTitle, profileSummary,
                                        { profileName = it }, { profileTitle = it }, { profileSummary = it },
                                        aiState, Triple(dot1, dot2, dot3), aiShimmer
                                    ) {
                                        if (aiState == AiState.IDLE) {
                                            aiState = AiState.THINKING
                                        }
                                    }
                                    "Compétences" -> SkillsContent(
                                        skills, { skills = skills - it }, { if (it !in skills) skills = skills + it },
                                        suggestions, showSuggestions, { showSuggestions = !showSuggestions }
                                    )
                                    "Expérience" -> ExperienceEditorContent()
                                    "Formation"  -> FormationEditorContent()
                                }
                            }
                        }
                        Spacer(Modifier.height(90.dp))
                    }
                }
            }
        }

        // ── Dark gradient export bar — slides up from bottom ─────
        Box(
            modifier = Modifier.align(Alignment.BottomCenter).fillMaxWidth().offset(y = exportY)
                .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
                .background(Brush.verticalGradient(listOf(EDarkMid, EDark)))
        ) {
            Row(
                modifier = Modifier.fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 14.dp).padding(bottom = 16.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text("Score ATS", fontSize = 11.sp, color = EWhite.copy(alpha = 0.50f))
                    Row(verticalAlignment = Alignment.Bottom, horizontalArrangement = Arrangement.spacedBy(3.dp)) {
                        Text(
                            "92",
                            style = TextStyle(
                                brush = Brush.linearGradient(listOf(EAccent, AccentCo)),
                                fontSize = 24.sp, fontWeight = FontWeight.ExtraBold
                            )
                        )
                        Text("/100", fontSize = 12.sp, color = EWhite.copy(alpha = 0.38f),
                            modifier = Modifier.padding(bottom = 3.dp))
                    }
                }
                val exportSrc = remember { MutableInteractionSource() }
                val exportPressed by exportSrc.collectIsPressedAsState()
                val exportScale by animateFloatAsState(
                    if (exportPressed) 0.96f else 1f,
                    spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "exp_s"
                )
                Box(
                    modifier = Modifier.height(48.dp).scale(exportScale)
                        .clip(RoundedCornerShape(14.dp))
                        .background(Brush.linearGradient(listOf(EAccent, Color(0xFF9B6AEE))))
                        .clickable(interactionSource = exportSrc, indication = null, onClick = onExport)
                        .padding(horizontal = 20.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text("Exporter PDF ↑", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }

        // AI done toast
        if (aiState == AiState.DONE) {
            LaunchedEffect(Unit) { delay(2500); aiState = AiState.IDLE }
            AnimatedVisibility(
                visible = true,
                enter = slideInVertically(spring(Spring.DampingRatioMediumBouncy)) { -it } + fadeIn(tween(200)),
                modifier = Modifier.align(Alignment.TopCenter).padding(top = 140.dp).padding(horizontal = 24.dp)
            ) {
                Box(
                    modifier = Modifier.fillMaxWidth()
                        .clip(RoundedCornerShape(16.dp))
                        .background(Brush.linearGradient(listOf(EDark, EAccent.copy(0.75f))))
                        .border(1.dp, EAccent.copy(0.40f), RoundedCornerShape(16.dp))
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        Box(modifier = Modifier.size(32.dp).clip(CircleShape)
                            .background(Brush.linearGradient(listOf(EAccent, AccentCo))),
                            contentAlignment = Alignment.Center) {
                            Text("✦", fontSize = 14.sp, color = Color.White, fontWeight = FontWeight.ExtraBold)
                        }
                        Column {
                            Text("Reformulation prête !", fontSize = 14.sp, fontWeight = FontWeight.Bold, color = EWhite)
                            Text("L'IA a optimisé votre expérience pour les ATS.", fontSize = 12.sp, color = EWhite.copy(0.72f))
                        }
                    }
                }
            }
        }
    }
}

// ── Accordion section with AnimatedVisibility ─────────────────────────────────

@Composable
private fun AccordionSection(
    title: String,
    expanded: Boolean,
    onToggle: () -> Unit,
    content: @Composable () -> Unit
) {
    val chevronRotation by animateFloatAsState(
        if (expanded) 0f else -90f,
        spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium),
        label = "chevron"
    )

    Surface(
        shape = RoundedCornerShape(16.dp),
        color = ECard,
        shadowElevation = if (expanded) 8.dp else 3.dp
    ) {
        Column {
            val headerSrc = remember { MutableInteractionSource() }
            Row(
                modifier = Modifier.fillMaxWidth()
                    .clickable(headerSrc, null) { onToggle() }
                    .padding(horizontal = 18.dp, vertical = 15.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(title, fontSize = 15.sp, fontWeight = FontWeight.Bold, color = EInk)
                Text("▼", fontSize = 11.sp, color = EInk.copy(alpha = 0.32f),
                    modifier = Modifier.scale(scaleX = 1f, scaleY = if (expanded) -1f else 1f))
            }
            AnimatedVisibility(
                visible = expanded,
                enter = fadeIn(tween(180)) + expandVertically(
                    spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium),
                    expandFrom = Alignment.Top
                ),
                exit = fadeOut(tween(140)) + shrinkVertically(
                    tween(180), shrinkTowards = Alignment.Top
                )
            ) {
                Column {
                    HorizontalDivider(color = EInk.copy(alpha = 0.07f))
                    Box(modifier = Modifier.padding(18.dp)) { content() }
                }
            }
        }
    }
}

// ── Profil content with shimmer AI button ─────────────────────────────────────

@Composable
private fun ProfilContent(
    name: String, title: String, summary: String,
    onName: (String) -> Unit, onTitle: (String) -> Unit, onSummary: (String) -> Unit,
    aiState: AiState,
    dots: Triple<Float, Float, Float>,
    shimmer: Brush,
    onAiReform: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(13.dp)) {
        EditorField("Nom complet", name, onName)
        EditorField("Titre professionnel", title, onTitle)
        OutlinedTextField(
            value = summary, onValueChange = onSummary,
            label = { Text("Résumé", fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            minLines = 3, maxLines = 5,
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = EInk.copy(alpha = 0.11f),
                focusedBorderColor = EAccent,
                unfocusedContainerColor = EBg.copy(alpha = 0.50f),
                focusedContainerColor = Color.White
            )
        )

        // AI button — shimmer overlay when THINKING
        val aiSrc = remember { MutableInteractionSource() }
        val aiPressed by aiSrc.collectIsPressedAsState()
        val aiScale by animateFloatAsState(
            if (aiPressed) 0.97f else 1f,
            spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "ai_btn_s"
        )
        val btnColor by animateColorAsState(
            when (aiState) {
                AiState.DONE -> SuccessGreen
                else -> EAccent
            },
            spring(Spring.DampingRatioNoBouncy, Spring.StiffnessMedium),
            label = "ai_btn_color"
        )

        Box(
            modifier = Modifier.fillMaxWidth().height(46.dp).scale(aiScale)
                .clip(RoundedCornerShape(13.dp))
                .background(btnColor)
                .clickable(aiSrc, null, enabled = aiState == AiState.IDLE) { onAiReform() },
            contentAlignment = Alignment.Center
        ) {
            // Shimmer overlay during THINKING
            if (aiState == AiState.THINKING) {
                Box(modifier = Modifier.fillMaxSize().background(shimmer))
            }

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                when (aiState) {
                    AiState.IDLE -> {
                        Text("✦", fontSize = 14.sp, color = Color.White)
                        Text("Reformuler avec l'IA", fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold, color = Color.White)
                    }
                    AiState.THINKING -> {
                        Text("✦  Analyse", fontSize = 14.sp, color = Color.White.copy(alpha = 0.75f))
                        Text("•", fontSize = 20.sp, modifier = Modifier.alpha(dots.first), color = Color.White)
                        Text("•", fontSize = 20.sp, modifier = Modifier.alpha(dots.second), color = Color.White)
                        Text("•", fontSize = 20.sp, modifier = Modifier.alpha(dots.third), color = Color.White)
                    }
                    AiState.DONE -> {
                        Text("✓  Reformulé !", fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold, color = Color.White)
                    }
                }
            }
        }
    }
}

// ── Skills content ────────────────────────────────────────────────────────────

@Composable
private fun SkillsContent(
    skills: List<String>, onRemove: (String) -> Unit, onAdd: (String) -> Unit,
    suggestions: List<String>, showSuggestions: Boolean, onToggle: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            skills.forEach { skill ->
                val chipSrc = remember { MutableInteractionSource() }
                val chipPressed by chipSrc.collectIsPressedAsState()
                val chipScale by animateFloatAsState(
                    if (chipPressed) 0.92f else 1f,
                    spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "chip_$skill"
                )
                Surface(
                    shape = RoundedCornerShape(10.dp),
                    color = EAccent.copy(alpha = 0.11f),
                    border = BorderStroke(1.dp, EAccent.copy(alpha = 0.28f)),
                    modifier = Modifier.scale(chipScale)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(skill, fontSize = 13.sp, color = EAccent, fontWeight = FontWeight.SemiBold)
                        Text("×", fontSize = 13.sp, color = EAccent.copy(alpha = 0.55f),
                            modifier = Modifier.clickable(chipSrc, null) { onRemove(skill) })
                    }
                }
            }
        }

        TextButton(onClick = onToggle, modifier = Modifier.fillMaxWidth()) {
            Text("✦  ${if (showSuggestions) "Masquer" else "Suggestions IA"}",
                fontSize = 13.sp, color = EAccent, fontWeight = FontWeight.SemiBold)
        }

        AnimatedVisibility(
            visible = showSuggestions,
            enter = fadeIn(tween(200)) + expandVertically(tween(200)),
            exit = fadeOut(tween(160)) + shrinkVertically(tween(160))
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Suggestions IA", fontSize = 11.sp, color = EInk.copy(alpha = 0.48f))
                FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    suggestions.filter { it !in skills }.forEach { s ->
                        val sChipSrc = remember { MutableInteractionSource() }
                        val sChipPressed by sChipSrc.collectIsPressedAsState()
                        val sChipScale by animateFloatAsState(
                            if (sChipPressed) 0.92f else 1f,
                            spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "sug_$s"
                        )
                        Surface(
                            shape = RoundedCornerShape(10.dp),
                            color = EBg,
                            border = BorderStroke(1.dp, EInk.copy(alpha = 0.12f)),
                            modifier = Modifier.scale(sChipScale).clickable(sChipSrc, null) { onAdd(s) }
                        ) {
                            Row(
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp),
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(5.dp)
                            ) {
                                Text("+", fontSize = 12.sp, color = EAccent)
                                Text(s, fontSize = 13.sp, color = EInk.copy(alpha = 0.68f))
                            }
                        }
                    }
                }
            }
        }
    }
}

// ── Experience & Formation editors ────────────────────────────────────────────

@Composable
private fun ExperienceEditorContent() {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        EditorField("Poste", "Développeuse Full-Stack", {})
        EditorField("Entreprise", "TechCorp SAS", {})
        EditorField("Période", "2021 – Présent", {})
        OutlinedTextField(
            value = "Développement d'applications mobiles Android avec Kotlin et Jetpack Compose. Amélioration des performances de 40 %.",
            onValueChange = {},
            label = { Text("Description", fontSize = 12.sp) },
            modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), minLines = 3,
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = EInk.copy(alpha = 0.11f), focusedBorderColor = EAccent)
        )
    }
}

@Composable
private fun FormationEditorContent() {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        EditorField("Diplôme", "Master Informatique", {})
        EditorField("Établissement", "Université Paris-Saclay", {})
        EditorField("Année", "2019", {})
    }
}

@Composable
private fun EditorField(label: String, value: String, onValueChange: (String) -> Unit) {
    OutlinedTextField(
        value = value, onValueChange = onValueChange,
        label = { Text(label, fontSize = 12.sp) },
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp), singleLine = true,
        colors = OutlinedTextFieldDefaults.colors(
            unfocusedBorderColor = EInk.copy(alpha = 0.11f),
            focusedBorderColor = EAccent,
            unfocusedContainerColor = EBg.copy(alpha = 0.50f),
            focusedContainerColor = Color.White
        )
    )
}

// ── Preview panel ─────────────────────────────────────────────────────────────

@Composable
private fun PreviewPanel(name: String, title: String, summary: String, skills: List<String>) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(18.dp),
        color = ECard, shadowElevation = 12.dp
    ) {
        Column(modifier = Modifier.padding(24.dp)) {
            Text(name, fontSize = 22.sp, fontWeight = FontWeight.ExtraBold, color = EInk)
            Text(title, fontSize = 14.sp, color = EAccent, fontWeight = FontWeight.SemiBold)
            Text("amina@example.com  •  Paris, France", fontSize = 11.sp, color = EInk.copy(alpha = 0.42f))
            Spacer(Modifier.height(14.dp))
            HorizontalDivider(color = EAccent.copy(alpha = 0.28f), thickness = 1.5.dp)
            Spacer(Modifier.height(14.dp))

            SectionHeader("Profil")
            Spacer(Modifier.height(6.dp))
            Text(summary, fontSize = 11.5.sp, color = EInk.copy(alpha = 0.78f), lineHeight = 17.sp)
            Spacer(Modifier.height(16.dp))

            SectionHeader("Expérience")
            Spacer(Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Column {
                    Text("Développeuse Full-Stack", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = EInk)
                    Text("TechCorp SAS", fontSize = 11.sp, color = EInk.copy(alpha = 0.52f))
                }
                Text("2021 – Présent", fontSize = 10.sp, color = EInk.copy(alpha = 0.38f))
            }
            Spacer(Modifier.height(5.dp))
            Text("Développement mobile Android avec Kotlin et Jetpack Compose. Amélioration des performances de 40 %.",
                fontSize = 11.sp, color = EInk.copy(alpha = 0.68f), lineHeight = 16.sp)
            Spacer(Modifier.height(16.dp))

            SectionHeader("Compétences")
            Spacer(Modifier.height(8.dp))
            FlowRow(horizontalArrangement = Arrangement.spacedBy(6.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                skills.forEach { s ->
                    Surface(shape = RoundedCornerShape(6.dp), color = EAccent.copy(alpha = 0.09f)) {
                        Text(s, fontSize = 10.sp, color = EAccent, fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp))
                    }
                }
            }
            Spacer(Modifier.height(16.dp))

            SectionHeader("Formation")
            Spacer(Modifier.height(8.dp))
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Column {
                    Text("Master Informatique", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = EInk)
                    Text("Université Paris-Saclay", fontSize = 11.sp, color = EInk.copy(alpha = 0.52f))
                }
                Text("2019", fontSize = 10.sp, color = EInk.copy(alpha = 0.38f))
            }
        }
    }
}

@Composable
private fun SectionHeader(text: String) {
    Text(text, fontSize = 13.sp, fontWeight = FontWeight.ExtraBold, color = EAccent, letterSpacing = 0.5.sp)
}
