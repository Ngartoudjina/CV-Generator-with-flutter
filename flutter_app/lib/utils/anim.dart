import 'dart:async';

import 'package:flutter/material.dart';

/// Port de `ui/anim/AnimUtils.kt`.
///
/// Équivalences retenues :
///
/// | Compose                                              | Flutter                          |
/// |------------------------------------------------------|----------------------------------|
/// | `rememberStaggerVisible(n)`                          | [StaggerBuilder]                 |
/// | `EntranceItem(visible, fromY, fromScale)`            | [EntranceItem]                   |
/// | `rememberFloatOffset()`                              | [FloatingBox]                    |
/// | `rememberPulseAlpha()`                               | [PulseBuilder]                   |
/// | `rememberShimmerBrush()`                             | [ShimmerOverlay]                 |
/// | `animateIntAsState`                                  | [AnimatedIntBuilder]             |
/// | `collectIsPressedAsState` + `Modifier.scale`         | [PressScale]                     |
/// | `TextStyle(brush = Brush.linearGradient(...))`       | [GradientText]                   |
///
/// Note : Compose utilise des ressorts physiques (`spring(DampingRatio…)`).
/// Flutter n'expose pas le même solveur en animation implicite ; on utilise
/// [Curves.easeOutBack] qui produit le même léger dépassement élastique.
const Curve kBouncy = Curves.easeOutBack;

/// Révélation en cascade — bascule chacun des [count] booléens à `true`
/// l'un après l'autre. [startDelay] avant le premier, [stepDelay] entre chaque.
class StaggerBuilder extends StatefulWidget {
  const StaggerBuilder({
    super.key,
    required this.count,
    required this.builder,
    this.startDelay = const Duration(milliseconds: 120),
    this.stepDelay = const Duration(milliseconds: 75),
  });

  final int count;
  final Duration startDelay;
  final Duration stepDelay;
  final Widget Function(BuildContext context, List<bool> visible) builder;

  @override
  State<StaggerBuilder> createState() => _StaggerBuilderState();
}

class _StaggerBuilderState extends State<StaggerBuilder> {
  late final List<bool> _visible = List<bool>.filled(widget.count, false);
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.count; i++) {
      final delay = widget.startDelay + widget.stepDelay * i;
      _timers.add(Timer(delay, () {
        if (!mounted) return;
        setState(() => _visible[i] = true);
      }));
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _visible);
}

/// Animation d'entrée : fondu + glissement élastique depuis [fromY] px plus bas
/// + mise à l'échelle optionnelle depuis [fromScale].
class EntranceItem extends StatefulWidget {
  const EntranceItem({
    super.key,
    required this.visible,
    required this.child,
    this.fromY = 24,
    this.fromScale = 1,
  });

  final bool visible;
  final double fromY;
  final double fromScale;
  final Widget child;

  @override
  State<EntranceItem> createState() => _EntranceItemState();
}

class _EntranceItemState extends State<EntranceItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
    reverseDuration: const Duration(milliseconds: 280),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, 0.65, curve: Curves.easeOut),
  );

  late final Animation<double> _spring =
      CurvedAnimation(parent: _c, curve: kBouncy, reverseCurve: Curves.easeIn);

  @override
  void initState() {
    super.initState();
    if (widget.visible) _c.forward();
  }

  @override
  void didUpdateWidget(covariant EntranceItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible != oldWidget.visible) {
      widget.visible ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _spring.value;
        final dy = widget.fromY * (1 - t);
        final scale = widget.fromScale + (1 - widget.fromScale) * t;
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, dy),
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

/// Oscillation verticale infinie de type sinusoïdal.
class FloatingBox extends StatefulWidget {
  const FloatingBox({
    super.key,
    required this.child,
    this.amplitude = 5,
    this.period = const Duration(milliseconds: 2800),
  });

  final Widget child;
  final double amplitude;
  final Duration period;

  @override
  State<FloatingBox> createState() => _FloatingBoxState();
}

class _FloatingBoxState extends State<FloatingBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) {
        final y = -widget.amplitude + curved.value * widget.amplitude * 2;
        return Transform.translate(offset: Offset(0, y), child: child);
      },
    );
  }
}

/// Alpha pulsé — anneaux lumineux, indicateurs « respirants ».
class PulseBuilder extends StatefulWidget {
  const PulseBuilder({
    super.key,
    required this.builder,
    this.min = 0.20,
    this.max = 0.70,
    this.duration = const Duration(milliseconds: 1000),
  });

  final double min;
  final double max;
  final Duration duration;
  final Widget Function(BuildContext context, double alpha) builder;

  @override
  State<PulseBuilder> createState() => _PulseBuilderState();
}

class _PulseBuilderState extends State<PulseBuilder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) => widget.builder(
        context,
        widget.min + curved.value * (widget.max - widget.min),
      ),
    );
  }
}

/// Balayage lumineux de gauche à droite — état « IA en cours ».
class ShimmerOverlay extends StatefulWidget {
  const ShimmerOverlay({
    super.key,
    this.color = const Color(0x8CFFFFFF),
    this.duration = const Duration(milliseconds: 1600),
  });

  final Color color;
  final Duration duration;

  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // -1 → 2 : la bande traverse largement le widget de part en part.
        final t = -1 + _c.value * 3;
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(t - 0.6, 0),
              end: Alignment(t + 0.6, 0),
              colors: [
                widget.color.withValues(alpha: 0),
                widget.color,
                widget.color.withValues(alpha: 0),
              ],
            ),
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

/// Équivalent de `animateIntAsState` — compteur animé de 0 vers [value].
class AnimatedIntBuilder extends StatelessWidget {
  const AnimatedIntBuilder({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 1000),
    this.curve = Curves.easeInOut,
  });

  final int value;
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext context, int current) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, v, _) => builder(context, v.round()),
    );
  }
}

/// Réduction à l'appui — remplace `collectIsPressedAsState()` + `Modifier.scale`.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.96,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: active ? (_) => _set(true) : null,
      onTapUp: active ? (_) => _set(false) : null,
      onTapCancel: active ? () => _set(false) : null,
      onTap: active ? widget.onTap : null,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 160),
        curve: kBouncy,
        child: widget.child,
      ),
    );
  }
}

/// Texte peint par un dégradé — remplace `TextStyle(brush = Brush.linearGradient)`.
class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
    this.textAlign,
  });

  final String text;
  final Gradient gradient;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient
          .createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

/// Bordure en dégradé — Compose permet `Modifier.border(width, Brush, Shape)`,
/// Flutter non : on peint le dégradé puis on masque l'intérieur.
class GradientBorder extends StatelessWidget {
  const GradientBorder({
    super.key,
    required this.child,
    required this.gradient,
    required this.radius,
    this.width = 1,
    this.fill,
    this.fillGradient,
  });

  final Widget child;
  final Gradient gradient;
  final double radius;
  final double width;
  final Color? fill;
  final Gradient? fillGradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Padding(
        padding: EdgeInsets.all(width),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fillGradient == null ? (fill ?? Colors.transparent) : null,
            gradient: fillGradient,
            borderRadius: BorderRadius.circular(radius - width),
          ),
          child: child,
        ),
      ),
    );
  }
}
