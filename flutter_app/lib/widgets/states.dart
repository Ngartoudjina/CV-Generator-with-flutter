import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// États vide, chargement et succès — `maquettes/09_etats.jpg`.
///
/// La maquette les présente sur un même écran, mais ce n'est pas un écran :
/// ce sont trois motifs à réemployer. Le portage n'en avait aucun — une liste
/// vide restait vide, une attente ne se voyait pas, et un export réussi ne
/// donnait qu'une bannière système.

/// Rien à afficher, et une seule action pour en sortir.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.xxxl,
        vertical: Space.xxxl,
      ),
      child: Column(
        children: [
          // Une feuille en pointillés plutôt qu'une icône : on annonce ce qui
          // manque, un document.
          Container(
            width: 72,
            height: 88,
            padding: const EdgeInsets.all(Space.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.xs),
              border: Border.all(color: Paper.ruleStrong),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 28,
                height: 3,
                color: Paper.ruleStrong,
              ),
            ),
          ),

          const SizedBox(height: Space.xl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Serif.title.copyWith(fontSize: 24),
          ),
          const SizedBox(height: Space.sm),
          Text(message, textAlign: TextAlign.center, style: Sans.body),

          if (actionLabel != null) ...[
            const SizedBox(height: Space.xl),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Radii.md),
                boxShadow: Shadow.floating,
              ),
              child: FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Attente : des barres grises à la forme du contenu à venir, et une ligne
/// qui dit ce qui se passe.
///
/// Un indicateur circulaire ne dit rien ; un squelette annonce la structure,
/// et le libellé annonce l'opération.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, required this.label, this.rows = 2});

  final String label;
  final int rows;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

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
        final opacity = 0.45 + _c.value * 0.35;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < widget.rows; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.lg),
                  child: Opacity(
                    opacity: opacity,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Paper.tint,
                            borderRadius: BorderRadius.circular(Radii.xs),
                          ),
                        ),
                        const SizedBox(width: Space.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final w in [1.0, 0.72, 0.4]) ...[
                                FractionallySizedBox(
                                  widthFactor: w,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Paper.tint,
                                      borderRadius:
                                          BorderRadius.circular(Radii.xs),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: Space.sm),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Accent.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '✦',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: Space.md),
                  Text(widget.label, style: Mono.overlineAccent),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Confirmation d'une action terminée, présentée en feuille modale.
///
/// Le portage se contentait d'une bannière système, qui disparaissait avant
/// qu'on ait lu le nom du fichier — et sans proposer de le partager.
class SuccessSheet extends StatelessWidget {
  const SuccessSheet({
    super.key,
    required this.title,
    required this.detail,
    required this.onShare,
    required this.onDone,
  });

  final String title;

  /// Le nom du fichier produit, en monospace : c'est une donnée technique,
  /// et l'utilisateur doit pouvoir la relire caractère par caractère.
  final String detail;

  final VoidCallback onShare;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.xl,
        Space.xxl,
        Space.xl,
        MediaQuery.of(context).padding.bottom + Space.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: Shadow.floating,
            ),
            child: Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Accent.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 32, color: Colors.white),
            ),
          ),
          const SizedBox(height: Space.xl),
          Text(title, style: Serif.title.copyWith(fontSize: 26)),
          const SizedBox(height: Space.sm),
          Text(
            detail.toUpperCase(),
            textAlign: TextAlign.center,
            style: Mono.overline,
          ),
          const SizedBox(height: Space.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onShare,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Accent.redWash,
                    foregroundColor: Accent.red,
                    side: const BorderSide(color: Accent.redLine),
                  ),
                  child: const Text('Partager'),
                ),
              ),
              const SizedBox(width: Space.md),
              Expanded(
                child: OutlinedButton(
                  onPressed: onDone,
                  child: const Text('Terminé'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
