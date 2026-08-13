package com.cvgenerator.ui.anim

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.*
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import kotlinx.coroutines.delay

/**
 * Staggered reveal — flips each of [count] booleans to true one by one.
 * [startDelay] before first flip, [stepDelay] between each subsequent flip.
 */
@Composable
fun rememberStaggerVisible(
    count: Int,
    startDelay: Long = 120L,
    stepDelay: Long = 75L
): List<Boolean> {
    val states = remember { mutableStateListOf(*Array(count) { false }) }
    LaunchedEffect(Unit) {
        delay(startDelay)
        for (i in 0 until count) {
            states[i] = true
            delay(stepDelay)
        }
    }
    return states
}

/** Infinite sine-like vertical oscillation — use as `Modifier.offset(y = ...)`. */
@Composable
fun rememberFloatOffset(amplitude: Float = 5f, periodMs: Int = 2800): Dp {
    val inf = rememberInfiniteTransition(label = "float")
    val y by inf.animateFloat(
        initialValue = -amplitude, targetValue = amplitude,
        animationSpec = infiniteRepeatable(
            tween(periodMs, easing = FastOutSlowInEasing), RepeatMode.Reverse
        ),
        label = "float_y"
    )
    return y.dp
}

/** Left-to-right shimmer brush — overlay on backgrounds during loading/AI states. */
@Composable
fun rememberShimmerBrush(color: Color, spanPx: Float = 280f): Brush {
    val inf = rememberInfiniteTransition(label = "shimmer")
    val x by inf.animateFloat(
        initialValue = -spanPx,
        targetValue = spanPx * 2.5f,
        animationSpec = infiniteRepeatable(tween(1600, easing = LinearEasing)),
        label = "shimmer_x"
    )
    return Brush.linearGradient(
        colors = listOf(Color.Transparent, color, Color.Transparent),
        start = Offset(x, 0f),
        end = Offset(x + spanPx, 80f)
    )
}

/** Pulsing alpha — use for glow rings, breathing indicators. */
@Composable
fun rememberPulseAlpha(min: Float = 0.20f, max: Float = 0.70f, durationMs: Int = 1000): Float {
    val inf = rememberInfiniteTransition(label = "pulse")
    val a by inf.animateFloat(
        initialValue = min, targetValue = max,
        animationSpec = infiniteRepeatable(
            tween(durationMs, easing = FastOutSlowInEasing), RepeatMode.Reverse
        ),
        label = "pulse_a"
    )
    return a
}

/**
 * Entrance animation: fades in + spring-slides from [fromY]dp below
 * + optional spring-scale from [fromScale].
 * When [visible] flips true the spring overshoots slightly → elastic feel.
 */
@Composable
fun EntranceItem(
    visible: Boolean,
    fromY: Float = 24f,
    fromScale: Float = 1f,
    content: @Composable () -> Unit
) {
    val alpha by animateFloatAsState(
        targetValue = if (visible) 1f else 0f,
        animationSpec = tween(400),
        label = "ent_alpha"
    )
    val yDp by animateDpAsState(
        targetValue = if (visible) 0.dp else fromY.dp,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMediumLow),
        label = "ent_y"
    )
    val s by animateFloatAsState(
        targetValue = if (visible) 1f else fromScale,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMediumLow),
        label = "ent_s"
    )
    Box(modifier = Modifier.alpha(alpha).offset(y = yDp).scale(s)) { content() }
}
