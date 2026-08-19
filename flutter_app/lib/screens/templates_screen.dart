import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cv_font.dart';
import '../state/cv_library.dart';
import '../theme/design_tokens.dart';

/// Onglet Modèles — le choix d'apparence du document.
///
/// L'onglet existait dans la maquette `04_mes-cv.jpg` mais restait vide. Il
/// accueille ici le choix de police du CV, qui relève de la même famille de
/// décisions que le modèle de mise en page (« Ravel », « Ligne »).
///
/// Chaque proposition est **rendue dans sa propre police** : un nom de famille
/// ne dit rien à qui ne connaît pas la typographie, un échantillon si.
class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = context.watch<CvLibrary>();
    final doc = library.current;
    final selected = CvFont.fromFamily(doc?.fontFamily);

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.xl,
            Space.md,
            Space.xl,
            Space.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modèles', style: Serif.title),
              const SizedBox(height: Space.xs),
              Text(
                doc == null
                    ? 'AUCUN CV SÉLECTIONNÉ'
                    : 'APPARENCE DE « ${doc.title.toUpperCase()} »',
                style: Mono.overline,
              ),
            ],
          ),
        ),

        const Divider(color: Paper.rule, height: 1),

        const Padding(
          padding: EdgeInsets.fromLTRB(Space.xl, Space.xl, Space.xl, Space.md),
          child: Text('POLICE DU DOCUMENT', style: Mono.overlineAccent),
        ),

        for (final font in CvFont.values)
          _FontOption(
            font: font,
            selected: font == selected,
            enabled: doc != null,
            onTap: () => library.setFont(doc!.id, font.family),
          ),

        // Une précision qui évite un contresens fréquent : on croit souvent
        // qu'une police « passe mieux » les filtres.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.xl,
            Space.xl,
            Space.xl,
            Space.xl,
          ),
          child: Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: BoxDecoration(
              color: Paper.tint,
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Pen.muted,
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Text(
                    "Le choix de police n'influence pas le score ATS : les "
                    'filtres lisent le texte du PDF, pas son dessin. '
                    "C'est une question de lisibilité et de ton.",
                    style: Sans.body.copyWith(fontSize: 13.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FontOption extends StatelessWidget {
  const _FontOption({
    required this.font,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final CvFont font;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: Motion.fast,
        decoration: BoxDecoration(
          color: selected ? Accent.redWash : Paper.bg,
          border: const Border(bottom: BorderSide(color: Paper.rule)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xl,
          vertical: Space.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    font.label,
                    style: Sans.itemTitle.copyWith(
                      color: selected ? Accent.red : Pen.primary,
                    ),
                  ),
                ),
                Text(font.kind.toUpperCase(), style: Mono.overline),
                if (selected) ...[
                  const SizedBox(width: Space.md),
                  const Icon(Icons.check, size: 18, color: Accent.red),
                ],
              ],
            ),

            const SizedBox(height: Space.sm),

            // L'échantillon : le nom et une ligne de CV, composés dans la
            // police proposée. C'est le seul argument qui compte.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Space.md),
              decoration: BoxDecoration(
                color: Paper.sheet,
                borderRadius: BorderRadius.circular(Radii.xs),
                border: Border.all(color: Paper.rule),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amina Diallo',
                    style: TextStyle(
                      fontFamily: font.family,
                      fontSize: 19,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Pen.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Piloté une équipe de 6 designers — conversion 18 % → 32 %.',
                    style: TextStyle(
                      fontFamily: font.family,
                      fontSize: 12,
                      height: 1.45,
                      color: Pen.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: Space.sm),
            Text(font.description, style: Sans.body.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
