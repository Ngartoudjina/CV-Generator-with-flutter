import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Écran d'accueil — `maquettes/01_accueil.jpg`.
///
/// Rupture complète avec le portage Compose (violet sombre, glassmorphisme,
/// blobs animés). La maquette est éditoriale : fond crème, titre serif, un
/// seul accent rouge, et une démonstration « avant → après » présentée comme
/// une vraie feuille de CV plutôt que comme une carte d'interface.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLogin,
  });

  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  /// Le mot qui change était déjà dans la version Compose, et « remarquer »
  /// est celui que fige la maquette. On le conserve : c'est la seule
  /// animation de l'écran, et elle porte la promesse du produit.
  static const _words = ['remarquer', 'recruter', 'choisir', 'embaucher'];

  int _wordIndex = 0;
  Timer? _wordTimer;

  @override
  void initState() {
    super.initState();
    _wordTimer = Timer.periodic(const Duration(milliseconds: 3200), (_) {
      if (mounted) {
        setState(() => _wordIndex = (_wordIndex + 1) % _words.length);
      }
    });
  }

  @override
  void dispose() {
    _wordTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paper.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barre de titre ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                Space.md,
                Space.xl,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('CV GENERATOR', style: Mono.overline),
                  GestureDetector(
                    onTap: widget.onLogin,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'CONNEXION',
                      style: Mono.overline.copyWith(color: Pen.primary),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: 300),
                    children: [
                      const SizedBox(height: Space.xxl),

                      // ── Accroche ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.xl,
                        ),
                        child: _Headline(word: _words[_wordIndex]),
                      ),

                      const SizedBox(height: Space.xl),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.xl,
                        ),
                        child: Text(
                          "Décrivez votre parcours en langage courant.\n"
                          "L'IA le réécrit en lignes précises, quantifiées et "
                          'lisibles par les filtres ATS.',
                          style: Sans.body.copyWith(height: 1.6),
                        ),
                      ),

                      const SizedBox(height: Space.xxl),
                      const Divider(color: Paper.rule, height: 1),
                      const SizedBox(height: Space.lg),

                      // ── Étiquettes de la démonstration ────────
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Space.xl,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('AVANT → APRÈS', style: Mono.overline),
                            Text('EXPÉRIENCE · LIGNE 3', style: Mono.overline),
                          ],
                        ),
                      ),

                      const SizedBox(height: Space.md),

                      // ── Feuille de CV ─────────────────────────
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: Space.xl),
                        child: _DemoSheet(),
                      ),
                    ],
                  ),

                  // Le bas de la feuille se fond dans le crème : la maquette
                  // la laisse volontairement coupée, pour suggérer la suite
                  // sans la montrer.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 190,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Paper.bg.withValues(alpha: 0),
                              Paper.bg.withValues(alpha: 0.85),
                              Paper.bg,
                            ],
                            stops: const [0, 0.35, 0.6],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Appel à l'action + mention ────────────────
                  Positioned(
                    left: Space.xl,
                    right: Space.xl,
                    bottom: Space.lg,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Radii.md),
                            boxShadow: Shadow.floating,
                          ),
                          child: FilledButton(
                            onPressed: widget.onGetStarted,
                            child: const Text('Créer mon CV  →'),
                          ),
                        ),
                        const SizedBox(height: Space.lg),
                        Text(
                          '12 000 CV CRÉÉS · SANS CARTE BANCAIRE',
                          style: Mono.overline.copyWith(fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Accroche ─────────────────────────────────────────────────────────────

class _Headline extends StatelessWidget {
  const _Headline({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Le CV qui vous fait', style: Serif.display),
        // Le mot se remplace sans glissement : un simple fondu, pour ne pas
        // faire bouger une ligne de titre en serif.
        AnimatedSwitcher(
          duration: Motion.normal,
          switchInCurve: Motion.enter,
          switchOutCurve: Motion.exit,
          child: Text(
            '$word.',
            key: ValueKey(word),
            style: Serif.display.copyWith(color: Accent.red),
          ),
        ),
      ],
    );
  }
}

// ── Feuille de démonstration ─────────────────────────────────────────────

class _DemoSheet extends StatelessWidget {
  const _DemoSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.xs),
        boxShadow: Shadow.sheet,
      ),
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.xl, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amina Diallo', style: Serif.name),
          const SizedBox(height: Space.xs),
          const Text('PRODUCT DESIGNER · PARIS', style: Mono.overlineAccent),
          const SizedBox(height: Space.xl),
          const Divider(color: Paper.rule, height: 1),
          const SizedBox(height: Space.lg),
          const Text('EXPÉRIENCE', style: Mono.overline),
          const SizedBox(height: Space.sm),
          const Text('Lead Designer — Ovalis', style: Sans.entryTitle),
          const SizedBox(height: 2),
          const Text("2022 — aujourd'hui", style: Mono.date),
          const SizedBox(height: Space.sm),
          const _Bullet("Refonte du parcours d'abonnement sur iOS et Android."),
          const _Bullet(
            "J'étais responsable de l'équipe design et on a amélioré les "
            'résultats.',
            struck: true,
          ),
          const SizedBox(height: Space.md),
          const _RewrittenBlock(),
          const SizedBox(height: Space.lg),
          const Text('Designer produit — Alan', style: Sans.entryTitle),
          const SizedBox(height: 2),
          const Text('2019 — 2022', style: Mono.date),
          const SizedBox(height: Space.sm),
          const _Bullet(
            'Conception du portail de remboursement, 400 000 utilisateurs.',
          ),
          const _Bullet(
            'Mise en place du design system et de sa documentation.',
          ),
          const SizedBox(height: Space.lg),
          const Divider(color: Paper.rule, height: 1),
          const SizedBox(height: Space.lg),
          const Text('COMPÉTENCES', style: Mono.overline),
          const SizedBox(height: Space.sm),
          Text(
            'Design système · Recherche utilisateur · Prototypage',
            style: Sans.sheetBody.copyWith(color: Pen.muted),
          ),
          const SizedBox(height: Space.xxxl),
        ],
      ),
    );
  }
}

/// Puce de CV. La maquette utilise un tiret court en gris clair, pas un point
/// médian : c'est un détail, mais c'est lui qui donne l'aspect « document ».
class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {this.struck = false});

  final String text;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    final style = struck
        ? Sans.sheetBody.copyWith(
            color: Pen.muted,
            decoration: TextDecoration.lineThrough,
            decorationColor: Pen.muted,
          )
        : Sans.sheetBody.copyWith(color: Pen.secondary);

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: Space.sm),
            child: Text('–', style: Sans.sheetBody.copyWith(color: Pen.faint)),
          ),
          Expanded(child: Text(text, style: style)),
        ],
      ),
    );
  }
}

/// Le bloc réécrit : filet rouge à gauche, métrique surlignée, et l'étiquette
/// qui attribue la phrase à l'IA.
class _RewrittenBlock extends StatelessWidget {
  const _RewrittenBlock();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Accent.red, width: 3)),
      ),
      padding: const EdgeInsets.only(left: Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: Sans.sheetBody.copyWith(
                color: Pen.primary,
                fontSize: 12,
                height: 1.55,
              ),
              children: const [
                TextSpan(
                  text: 'Piloté une équipe de 6 designers et porté le taux de '
                      'conversion de ',
                ),
                TextSpan(
                  text: '18 % à 32 %',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Accent.redDeep,
                    backgroundColor: Accent.redWash,
                  ),
                ),
                TextSpan(text: ' en trois trimestres.'),
              ],
            ),
          ),
          const SizedBox(height: Space.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.md,
              vertical: Space.sm,
            ),
            decoration: BoxDecoration(
              color: Accent.red,
              borderRadius: BorderRadius.circular(Radii.xs),
            ),
            child: Text(
              "✦  RÉÉCRIT PAR L'IA",
              style: Mono.badge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
