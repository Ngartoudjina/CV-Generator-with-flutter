package com.cvgenerator.ui.screens

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.*
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.*
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.cvgenerator.R
import com.cvgenerator.ui.anim.*
import com.cvgenerator.ui.theme.*

private val ADark    = Color(0xFF0D0920)
private val ADarkMid = Color(0xFF180C30)
private val ABg      = Color(0xFFF1ECFB)
private val AInk     = Color(0xFF1C1626)
private val AWhite   = Color(0xFFEFEBFF)
private val AAccent  = Accent

@Composable
fun AuthScreen(onAuthSuccess: () -> Unit, onBack: () -> Unit) {
    var isLogin  by remember { mutableStateOf(true) }
    var email    by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var name     by remember { mutableStateOf("") }
    var pwVisible by remember { mutableStateOf(false) }

    val vis = rememberStaggerVisible(8, startDelay = 80L, stepDelay = 60L)

    val toggleOffset by animateDpAsState(
        targetValue = if (isLogin) 4.dp else 153.dp,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium), label = "toggle"
    )

    val pwStrength = remember(password) {
        when {
            password.length >= 10 && password.any { it.isDigit() } && password.any { it.isUpperCase() } -> 4
            password.length >= 8 && (password.any { it.isDigit() } || password.any { it.isUpperCase() }) -> 3
            password.length >= 6 -> 2
            password.isNotEmpty() -> 1
            else -> 0
        }
    }
    val pwColors = listOf(Color.Transparent, ErrorRed, Color(0xFFF5A623), Color(0xFF85BB65), SuccessGreen)
    val pwLabels = listOf("", "Faible", "Moyen", "Bon", "Fort")

    Box(modifier = Modifier.fillMaxSize()) {
        // ── Background layers ──────────────────────────────────────
        // Dark gradient top
        Box(
            modifier = Modifier.fillMaxWidth().height(320.dp)
                .background(
                    Brush.verticalGradient(listOf(ADark, ADarkMid, ADark.copy(alpha = 0f)))
                )
        )
        // Light bottom fill
        Box(
            modifier = Modifier.fillMaxSize().padding(top = 270.dp).background(ABg)
        )

        // ── Scrollable content ─────────────────────────────────────
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(Modifier.height(52.dp))

            // Back button — ghost style on dark bg
            EntranceItem(visible = vis[0], fromY = -18f) {
                Row(modifier = Modifier.fillMaxWidth()) {
                    val backSrc = remember { MutableInteractionSource() }
                    val backPressed by backSrc.collectIsPressedAsState()
                    val backScale by animateFloatAsState(
                        if (backPressed) 0.88f else 1f,
                        spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "back_s"
                    )
                    Box(
                        modifier = Modifier.size(36.dp).scale(backScale)
                            .clip(RoundedCornerShape(10.dp))
                            .background(AWhite.copy(alpha = 0.12f))
                            .border(1.dp, AWhite.copy(alpha = 0.18f), RoundedCornerShape(10.dp))
                            .clickable(interactionSource = backSrc, indication = null, onClick = onBack),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("←", fontSize = 18.sp, color = AWhite)
                    }
                }
            }

            Spacer(Modifier.height(24.dp))

            // Large logo on dark section
            EntranceItem(visible = vis[1], fromY = 24f, fromScale = 0.78f) {
                Image(
                    painter = painterResource(R.drawable.logo_icon),
                    contentDescription = "CV Generator",
                    modifier = Modifier.size(88.dp),
                    contentScale = ContentScale.Fit
                )
            }

            Spacer(Modifier.height(16.dp))

            // Title + subtitle — white on dark
            EntranceItem(visible = vis[2], fromY = 18f) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text(
                        if (isLogin) "Bon retour 👋" else "Créer un compte",
                        fontSize = 26.sp, fontWeight = FontWeight.ExtraBold, color = AWhite
                    )
                    Spacer(Modifier.height(4.dp))
                    Text(
                        if (isLogin) "Connectez-vous pour accéder à vos CVs."
                        else "Rejoignez 12 000+ candidats.",
                        fontSize = 14.sp, color = AWhite.copy(alpha = 0.58f)
                    )
                }
            }

            Spacer(Modifier.height(28.dp))

            // ── Segmented toggle ───────────────────────────────────
            EntranceItem(visible = vis[3], fromY = 18f, fromScale = 0.94f) {
                Box(
                    modifier = Modifier.fillMaxWidth().height(46.dp)
                        .clip(RoundedCornerShape(14.dp))
                        .background(AInk.copy(alpha = 0.10f))
                ) {
                    Box(
                        modifier = Modifier.offset(x = toggleOffset).width(153.dp).fillMaxHeight()
                            .padding(4.dp).clip(RoundedCornerShape(10.dp)).background(Color.White)
                    )
                    Row(modifier = Modifier.fillMaxSize()) {
                        listOf("Connexion", "Inscription").forEachIndexed { i, label ->
                            Box(
                                modifier = Modifier.weight(1f).fillMaxHeight().clickable { isLogin = i == 0 },
                                contentAlignment = Alignment.Center
                            ) {
                                val textAlpha by animateFloatAsState(
                                    if ((i == 0) == isLogin) 1f else 0.45f, tween(200), label = "ta_$i"
                                )
                                val textScale by animateFloatAsState(
                                    if ((i == 0) == isLogin) 1f else 0.95f,
                                    spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium), label = "ts_$i"
                                )
                                Text(label, fontSize = 14.sp,
                                    fontWeight = if ((i == 0) == isLogin) FontWeight.Bold else FontWeight.Normal,
                                    color = AInk.copy(alpha = textAlpha),
                                    modifier = Modifier.scale(textScale))
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // ── Glass form card ────────────────────────────────────
            EntranceItem(visible = vis[4], fromY = 44f, fromScale = 0.94f) {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(22.dp),
                    color = Color.White.copy(alpha = 0.92f),
                    border = BorderStroke(1.dp, AInk.copy(alpha = 0.07f)),
                    shadowElevation = 20.dp
                ) {
                    Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(14.dp)) {
                        AnimatedVisibility(
                            visible = !isLogin,
                            enter = fadeIn(tween(220)) + expandVertically(spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium)),
                            exit = fadeOut(tween(160)) + shrinkVertically(tween(160))
                        ) {
                            AuthField("Prénom & Nom", name, { name = it }, "👤", "Amina Diallo")
                        }
                        AuthField("Adresse e-mail", email, { email = it }, "✉", "vous@exemple.com",
                            keyboardType = KeyboardType.Email)
                        Column {
                            AuthField("Mot de passe", password, { password = it }, "🔑", "••••••••",
                                keyboardType = KeyboardType.Password, isPassword = true,
                                pwVisible = pwVisible, onTogglePw = { pwVisible = !pwVisible })
                            AnimatedVisibility(
                                visible = !isLogin && password.isNotEmpty(),
                                enter = fadeIn(tween(200)) + expandVertically(tween(200)),
                                exit = fadeOut(tween(150)) + shrinkVertically(tween(150))
                            ) {
                                Column {
                                    Spacer(Modifier.height(8.dp))
                                    Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                        (1..4).forEach { lvl ->
                                            val barColor by animateColorAsState(
                                                if (pwStrength >= lvl) pwColors[pwStrength] else AInk.copy(0.12f),
                                                spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium), label = "pw_c_$lvl"
                                            )
                                            val barScale by animateFloatAsState(
                                                if (pwStrength >= lvl) 1f else 0.85f,
                                                spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "pw_s_$lvl"
                                            )
                                            Box(modifier = Modifier.weight(1f).height(4.dp)
                                                .scale(scaleX = 1f, scaleY = barScale)
                                                .clip(RoundedCornerShape(3.dp)).background(barColor))
                                        }
                                    }
                                    if (pwStrength > 0) {
                                        Spacer(Modifier.height(3.dp))
                                        Text(pwLabels[pwStrength], fontSize = 11.sp, color = pwColors[pwStrength],
                                            modifier = Modifier.align(Alignment.End))
                                    }
                                }
                            }
                        }
                        if (isLogin) {
                            Text("Mot de passe oublié ?", fontSize = 12.sp, color = AAccent,
                                fontWeight = FontWeight.SemiBold,
                                modifier = Modifier.align(Alignment.End).clickable { })
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // ── Gradient submit button ─────────────────────────────
            EntranceItem(visible = vis[5], fromY = 20f, fromScale = 0.94f) {
                val btnSrc = remember { MutableInteractionSource() }
                val btnPressed by btnSrc.collectIsPressedAsState()
                val btnScale by animateFloatAsState(
                    if (btnPressed) 0.965f else 1f,
                    spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "btn_s"
                )
                Box(
                    modifier = Modifier.fillMaxWidth().height(54.dp).scale(btnScale)
                        .clip(RoundedCornerShape(16.dp))
                        .background(Brush.linearGradient(listOf(AAccent, Color(0xFF9B6AEE))))
                        .clickable(interactionSource = btnSrc, indication = null, onClick = onAuthSuccess),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        if (isLogin) "Se connecter →" else "Créer mon compte →",
                        fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            EntranceItem(visible = vis[6], fromY = 12f) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    HorizontalDivider(modifier = Modifier.weight(1f), color = AInk.copy(alpha = 0.11f))
                    Text("  ou continuer avec  ", fontSize = 12.sp, color = AInk.copy(alpha = 0.38f))
                    HorizontalDivider(modifier = Modifier.weight(1f), color = AInk.copy(alpha = 0.11f))
                }
            }

            Spacer(Modifier.height(12.dp))

            EntranceItem(visible = vis[6], fromY = 16f, fromScale = 0.94f) {
                Row(horizontalArrangement = Arrangement.spacedBy(11.dp)) {
                    SocialBtn("Google", "G", onAuthSuccess, Modifier.weight(1f))
                    SocialBtn("LinkedIn", "in", onAuthSuccess, Modifier.weight(1f))
                }
            }

            Spacer(Modifier.height(22.dp))

            EntranceItem(visible = vis[7], fromY = 10f) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        if (isLogin) "Pas encore de compte ? " else "Déjà un compte ? ",
                        fontSize = 13.sp, color = AInk.copy(alpha = 0.52f)
                    )
                    Text(
                        if (isLogin) "Inscription" else "Connexion",
                        fontSize = 13.sp, color = AAccent, fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.clickable { isLogin = !isLogin }
                    )
                }
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}

// ── Private helpers ───────────────────────────────────────────────────────────

@Composable
private fun AuthField(
    label: String, value: String, onValueChange: (String) -> Unit,
    icon: String, placeholder: String,
    keyboardType: KeyboardType = KeyboardType.Text,
    isPassword: Boolean = false, pwVisible: Boolean = false,
    onTogglePw: (() -> Unit)? = null
) {
    Column {
        Text(label, fontSize = 12.sp, fontWeight = FontWeight.SemiBold,
            color = AInk.copy(alpha = 0.52f), letterSpacing = 0.3.sp)
        Spacer(Modifier.height(5.dp))
        OutlinedTextField(
            value = value, onValueChange = onValueChange,
            modifier = Modifier.fillMaxWidth(),
            placeholder = { Text(placeholder, color = AInk.copy(alpha = 0.28f)) },
            shape = RoundedCornerShape(13.dp),
            visualTransformation = if (isPassword && !pwVisible) PasswordVisualTransformation() else VisualTransformation.None,
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
            leadingIcon = { Text(icon, fontSize = 16.sp, modifier = Modifier.padding(start = 12.dp)) },
            trailingIcon = if (onTogglePw != null) ({
                TextButton(onClick = onTogglePw, modifier = Modifier.padding(end = 4.dp)) {
                    Text(if (pwVisible) "Cacher" else "Voir", fontSize = 11.sp, color = AAccent)
                }
            }) else null,
            colors = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = AInk.copy(alpha = 0.11f),
                focusedBorderColor = AAccent,
                unfocusedContainerColor = Color(0xFFF8F5FF),
                focusedContainerColor = Color.White
            ),
            singleLine = true
        )
    }
}

@Composable
private fun SocialBtn(label: String, icon: String, onClick: () -> Unit, modifier: Modifier = Modifier) {
    val src = remember { MutableInteractionSource() }
    val pressed by src.collectIsPressedAsState()
    val scale by animateFloatAsState(
        if (pressed) 0.95f else 1f,
        spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessHigh), label = "soc_$label"
    )
    OutlinedButton(
        onClick = onClick,
        modifier = modifier.height(48.dp).scale(scale),
        shape = RoundedCornerShape(13.dp),
        border = BorderStroke(1.dp, AInk.copy(alpha = 0.12f)),
        colors = ButtonDefaults.outlinedButtonColors(containerColor = Color.White, contentColor = AInk),
        interactionSource = src
    ) {
        Text(icon, fontSize = 15.sp, fontWeight = FontWeight.ExtraBold, color = AAccent)
        Spacer(Modifier.width(7.dp))
        Text(label, fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
    }
}
