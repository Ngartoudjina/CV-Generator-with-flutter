import 'package:flutter/material.dart';

import '../models/cv_data.dart';
import '../models/cv_section.dart';
import '../theme/design_tokens.dart';

/// Aperçu vivant du CV — la moitié haute de `maquettes/05_editeur.jpg`.
///
/// C'est un document, pas une carte d'interface : rayon minimal, ombre très
/// douce, puces en tiret, dates en monospace. La section en cours d'édition
/// est encadrée de rouge et marquée « EN COURS », de sorte que la saisie du
/// bas d'écran se voie immédiatement en haut — ce que l'accordéon du portage
/// rendait impossible.
class CvSheet extends StatelessWidget {
  const CvSheet({super.key, required this.data, this.highlighted});

  final CvData data;
  final CvSection? highlighted;

  @override
  Widget build(BuildContext context) {
    final info = data.personalInfo;

    return Container(
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.xs),
        boxShadow: Shadow.sheet,
      ),
      padding: const EdgeInsets.fromLTRB(
        Space.xl,
        Space.xl,
        Space.xl,
        Space.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Block(
            section: CvSection.profil,
            highlighted: highlighted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.fullName.trim().isEmpty ? 'Votre nom' : info.fullName,
                  style: Serif.name.copyWith(fontSize: 21),
                ),
                if (info.jobTitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(info.jobTitle.toUpperCase(), style: Mono.overlineAccent),
                ],
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          const Divider(color: Paper.rule, height: 1),
          const SizedBox(height: Space.md),
          if (info.summary.trim().isNotEmpty) ...[
            _SheetSection(
              label: 'PROFIL',
              section: CvSection.profil,
              highlighted: highlighted,
              children: [SheetBullet(info.summary)],
            ),
            const SizedBox(height: Space.md),
          ],
          if (data.experiences.isNotEmpty)
            _SheetSection(
              label: 'EXPÉRIENCE',
              section: CvSection.experience,
              highlighted: highlighted,
              children: [
                for (final e in data.experiences) ...[
                  Text(
                    [e.position, e.company]
                        .where((s) => s.trim().isNotEmpty)
                        .join(' — '),
                    style: Sans.entryTitle,
                  ),
                  if (e.period.isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(e.period, style: Mono.date),
                  ],
                  if (e.description.trim().isNotEmpty) ...[
                    const SizedBox(height: Space.xs),
                    SheetBullet(e.description),
                  ],
                  const SizedBox(height: Space.sm),
                ],
              ],
            ),
          if (data.skills.isNotEmpty) ...[
            const SizedBox(height: Space.sm),
            _SheetSection(
              label: 'COMPÉTENCES',
              section: CvSection.competences,
              highlighted: highlighted,
              children: [
                Text(
                  data.skills.map((s) => s.name).join(' · '),
                  style: Sans.sheetBody,
                ),
              ],
            ),
          ],
          if (data.educations.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            _SheetSection(
              label: 'FORMATION',
              section: CvSection.formation,
              highlighted: highlighted,
              children: [
                for (final e in data.educations) ...[
                  Text(e.degree, style: Sans.entryTitle),
                  if (e.schoolLine.trim().isNotEmpty)
                    Text(e.schoolLine, style: Sans.sheetBody),
                  if (e.years.isNotEmpty) Text(e.years, style: Mono.date),
                  const SizedBox(height: Space.sm),
                ],
              ],
            ),
          ],
          if (data.languages.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            _SheetSection(
              label: 'LANGUES',
              section: CvSection.langues,
              highlighted: highlighted,
              children: [
                Text(
                  data.languages
                      .map((l) => '${l.name} · ${l.level}')
                      .join('   '),
                  style: Sans.sheetBody,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Puce de document : un tiret gris clair, jamais un point médian. C'est ce
/// détail qui distingue une feuille de CV d'une liste d'interface.
class SheetBullet extends StatelessWidget {
  const SheetBullet(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: Space.sm),
            child: Text('–', style: Sans.sheetBody.copyWith(color: Pen.faint)),
          ),
          Expanded(child: Text(text, style: Sans.sheetBody)),
        ],
      ),
    );
  }
}

/// Encadre le bloc en cours d'édition et lui accroche le badge « EN COURS ».
/// Le badge chevauche la bordure supérieure, comme dans la maquette.
class _Block extends StatelessWidget {
  const _Block({
    required this.section,
    required this.highlighted,
    required this.child,
  });

  final CvSection section;
  final CvSection? highlighted;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (highlighted != section) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Accent.redWash,
            borderRadius: BorderRadius.circular(Radii.xs),
            border: Border.all(color: Accent.red, width: 1.5),
          ),
          padding: const EdgeInsets.all(Space.md),
          child: child,
        ),
        Positioned(
          top: -10,
          right: -1,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.sm,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Accent.red,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              'EN COURS',
              style: Mono.badge.copyWith(color: Colors.white, fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({
    required this.label,
    required this.section,
    required this.highlighted,
    required this.children,
  });

  final String label;
  final CvSection section;
  final CvSection? highlighted;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Block(
      section: section,
      highlighted: highlighted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Mono.overline),
          const SizedBox(height: Space.xs),
          ...children,
        ],
      ),
    );
  }
}
