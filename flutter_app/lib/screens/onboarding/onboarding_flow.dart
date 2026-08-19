import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cv_data.dart';
import '../../state/cv_model.dart';
import '../../theme/design_tokens.dart';

/// Onboarding — `maquettes/02_onboarding.jpg`.
///
/// Changement de nature, pas d'habillage. Le portage Compose enchaînait six
/// écrans de présentation — splash, trois arguments, persona, félicitations —
/// qui ne produisaient **rien** : l'utilisateur arrivait ensuite devant un CV
/// vide.
///
/// La maquette en fait un assistant de création en cinq étapes. Chaque étape
/// pose une question, propose des réponses, et **montre le CV se remplir en
/// direct** sous le champ de saisie. À la fin, le CV existe.
///
/// Le compteur « 2 CHAMPS SUR 8 » de l'aperçu est ce qui rend l'exercice
/// concret : on ne progresse pas dans un tunnel, on remplit un document.
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _step = 0;

  static const _steps = <_StepSpec>[
    _StepSpec(
      label: 'IDENTITÉ',
      question: 'Votre nom ?',
      hint: 'Le nom qui apparaîtra en haut du CV, tel que les recruteurs '
          'le liront.',
      fieldLabel: 'NOM COMPLET',
      placeholder: 'Amina Diallo',
      previewLabel: 'EN-TÊTE',
    ),
    _StepSpec(
      label: 'POSTE VISÉ',
      question: 'Quel poste visez-vous ?',
      hint: "L'IA adapte le vocabulaire, les verbes d'action et les mots-clés "
          'ATS à cette cible précise.',
      fieldLabel: 'INTITULÉ DU POSTE',
      placeholder: 'Product Designer',
      previewLabel: 'EN-TÊTE',
      suggestions: [
        'Product Designer',
        'UX Designer',
        'Designer produit',
        'Design Lead',
      ],
    ),
    _StepSpec(
      label: 'EXPÉRIENCE',
      question: 'Votre poste actuel ?',
      hint: 'Une seule ligne suffit pour commencer. Vous compléterez le reste '
          'dans l\'éditeur.',
      fieldLabel: 'POSTE ET ENTREPRISE',
      placeholder: 'Lead Designer — Ovalis',
      previewLabel: 'EXPÉRIENCE',
    ),
    _StepSpec(
      label: 'RÉALISATION',
      question: "Qu'avez-vous accompli ?",
      hint: 'Écrivez comme vous le diriez à l\'oral. L\'IA le réécrira en '
          'ligne quantifiée et lisible par les ATS.',
      fieldLabel: 'EN LANGAGE COURANT',
      placeholder: "J'ai géré une équipe et augmenté les ventes",
      previewLabel: 'EXPÉRIENCE',
      multiline: true,
    ),
    _StepSpec(
      label: 'COMPÉTENCES',
      question: 'Vos compétences clés ?',
      hint: 'Séparées par des virgules. Ce sont elles que les filtres ATS '
          'recherchent en premier.',
      fieldLabel: 'COMPÉTENCES',
      placeholder: 'Design système, Recherche utilisateur',
      previewLabel: 'COMPÉTENCES',
      suggestions: [
        'Design système',
        'Recherche utilisateur',
        'Prototypage',
        'Figma',
      ],
    ),
  ];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
    } else {
      widget.onComplete();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final spec = _steps[_step];

    return Scaffold(
      backgroundColor: Paper.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Barre et progression ──────────────────────────
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _step == 0 ? null : _back,
                    icon: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: _step == 0 ? Pen.faint : Pen.primary,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: Space.xl),
                    child: Text(
                      '${(_step + 1).toString().padLeft(2, '0')} / '
                      '${_steps.length.toString().padLeft(2, '0')}',
                      style: Mono.overline.copyWith(letterSpacing: 2),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.xl),
              child: _Progress(current: _step, total: _steps.length),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.xl,
                  Space.xxl,
                  Space.xl,
                  Space.xl,
                ),
                children: [
                  Text(
                    'ÉTAPE ${(_step + 1).toString().padLeft(2, '0')} · '
                    '${spec.label}',
                    style: Mono.overlineAccent,
                  ),
                  const SizedBox(height: Space.md),
                  Text(spec.question,
                      style: Serif.title.copyWith(fontSize: 27)),
                  const SizedBox(height: Space.md),
                  Text(spec.hint, style: Sans.body),

                  const SizedBox(height: Space.xxl),

                  // ── Saisie ────────────────────────────────────
                  _UnderlinedField(
                    key: ValueKey(_step),
                    label: spec.fieldLabel,
                    placeholder: spec.placeholder,
                    initial: _valueFor(model, _step),
                    multiline: spec.multiline,
                    onChanged: (v) => _write(model, _step, v),
                  ),

                  if (spec.suggestions.isNotEmpty) ...[
                    const SizedBox(height: Space.lg),
                    Wrap(
                      spacing: Space.sm,
                      runSpacing: Space.sm,
                      children: [
                        for (final s in spec.suggestions)
                          _SuggestionChip(
                            label: s,
                            selected: _isChosen(model, _step, s),
                            onTap: () => _choose(model, _step, s),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: Space.xxl),

                  // ── Aperçu en direct ──────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('APERÇU EN DIRECT', style: Mono.overline),
                      Builder(
                        builder: (_) {
                          final n = _filledFields(model.cvData);
                          return Text(
                            '${spec.previewLabel} · $n '
                            'CHAMP${n > 1 ? "S" : ""} SUR 8',
                            style: Mono.overline,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: Space.sm),
                  _LivePreview(data: model.cvData),
                ],
              ),
            ),

            // ── Actions ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Space.xl,
                0,
                Space.xl,
                Space.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.md),
                      boxShadow: Shadow.floating,
                    ),
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(
                        _step == _steps.length - 1 ? 'Terminer' : 'Continuer',
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _next,
                    child: Text(
                      'Passer cette étape',
                      style: Sans.button.copyWith(
                        fontSize: 15,
                        color: Pen.secondary,
                      ),
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

  // ── Liaison avec le modèle ──────────────────────────────────────────

  String _valueFor(CvModel m, int step) {
    final d = m.cvData;
    return switch (step) {
      0 => d.personalInfo.fullName,
      1 => d.personalInfo.jobTitle,
      2 => _experienceLine(d),
      3 => d.experiences.firstOrNull?.description ?? '',
      _ => d.skills.map((s) => s.name).join(', '),
    };
  }

  /// L'étape 3 saisit « Poste — Entreprise » sur une seule ligne : demander
  /// deux champs séparés ici alourdirait l'onboarding pour rien, l'éditeur
  /// les dissocie ensuite.
  String _experienceLine(CvData d) {
    final e = d.experiences.firstOrNull;
    if (e == null) return '';
    return [e.position, e.company]
        .where((s) => s.trim().isNotEmpty)
        .join(' — ');
  }

  void _write(CvModel m, int step, String value) {
    switch (step) {
      case 0:
        m.updatePersonalInfo(m.cvData.personalInfo.copyWith(fullName: value));
      case 1:
        m.updatePersonalInfo(m.cvData.personalInfo.copyWith(jobTitle: value));
      case 2:
        final parts = value.split('—');
        final position = parts.first.trim();
        final company = parts.length > 1 ? parts[1].trim() : '';
        final first = m.cvData.experiences.firstOrNull;
        if (first == null) {
          if (value.trim().isEmpty) return;
          m.addExperience(Experience(position: position, company: company));
        } else {
          m.updateExperience(
            first.copyWith(position: position, company: company),
          );
        }
      case 3:
        final first = m.cvData.experiences.firstOrNull;
        if (first == null) {
          if (value.trim().isEmpty) return;
          m.addExperience(Experience(description: value));
        } else {
          m.updateExperience(first.copyWith(description: value));
        }
      default:
        // Les compétences se saisissent en une ligne séparée par des
        // virgules : on reconstruit la liste à chaque frappe plutôt que de
        // gérer un état intermédiaire.
        for (final s in m.cvData.skills.toList()) {
          m.removeSkill(s.id);
        }
        for (final name in value.split(',')) {
          final n = name.trim();
          if (n.isNotEmpty) m.addSkill(Skill(name: n));
        }
    }
  }

  bool _isChosen(CvModel m, int step, String value) => switch (step) {
        1 => m.cvData.personalInfo.jobTitle.trim() == value,
        4 => m.cvData.skills.any((s) => s.name == value),
        _ => false,
      };

  void _choose(CvModel m, int step, String value) {
    if (step == 1) {
      m.updatePersonalInfo(m.cvData.personalInfo.copyWith(jobTitle: value));
      setState(() {});
      return;
    }
    if (step == 4) {
      final existing = m.cvData.skills.where((s) => s.name == value).toList();
      if (existing.isEmpty) {
        m.addSkill(Skill(name: value));
      } else {
        for (final s in existing) {
          m.removeSkill(s.id);
        }
      }
      setState(() {});
    }
  }

  /// Huit champs jalonnent un CV présentable. Le compteur donne à
  /// l'onboarding une mesure concrète, là où le portage n'offrait qu'une
  /// suite de pastilles.
  int _filledFields(CvData d) {
    final e = d.experiences.firstOrNull;
    final checks = [
      d.personalInfo.fullName,
      d.personalInfo.jobTitle,
      d.personalInfo.email,
      d.personalInfo.city,
      e?.position ?? '',
      e?.company ?? '',
      e?.description ?? '',
      d.skills.isEmpty ? '' : 'x',
    ];
    return checks.where((s) => s.trim().isNotEmpty).length;
  }
}

class _StepSpec {
  const _StepSpec({
    required this.label,
    required this.question,
    required this.hint,
    required this.fieldLabel,
    required this.placeholder,
    required this.previewLabel,
    this.suggestions = const [],
    this.multiline = false,
  });

  final String label;
  final String question;
  final String hint;
  final String fieldLabel;
  final String placeholder;
  final String previewLabel;
  final List<String> suggestions;
  final bool multiline;
}

// ── Progression ──────────────────────────────────────────────────────────

/// Cinq segments plutôt que des pastilles : la maquette montre une barre
/// segmentée, qui dit combien d'étapes restent et non seulement où l'on est.
class _Progress extends StatelessWidget {
  const _Progress({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: Motion.normal,
              height: 3,
              decoration: BoxDecoration(
                color: i <= current ? Accent.red : Paper.ruleStrong,
                borderRadius: BorderRadius.circular(Radii.full),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: Space.sm),
        ],
      ],
    );
  }
}

// ── Champ souligné ───────────────────────────────────────────────────────

/// Le champ de la maquette n'a ni cadre ni fond : du texte à grande taille
/// posé sur un filet rouge. C'est ce qui lui donne l'air d'écrire directement
/// dans le document plutôt que de remplir un formulaire.
class _UnderlinedField extends StatefulWidget {
  const _UnderlinedField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.initial,
    required this.onChanged,
    this.multiline = false,
  });

  final String label;
  final String placeholder;
  final String initial;
  final ValueChanged<String> onChanged;
  final bool multiline;

  @override
  State<_UnderlinedField> createState() => _UnderlinedFieldState();
}

class _UnderlinedFieldState extends State<_UnderlinedField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Mono.overline),
        const SizedBox(height: Space.sm),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          autofocus: false,
          maxLines: widget.multiline ? 3 : 1,
          style: Sans.body.copyWith(
            fontSize: widget.multiline ? 17 : 21,
            height: 1.35,
            color: Pen.primary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: false,
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: Space.sm),
            hintText: widget.placeholder,
            hintStyle: Sans.body.copyWith(
              fontSize: widget.multiline ? 17 : 21,
              color: Pen.faint,
              fontWeight: FontWeight.w400,
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Accent.red, width: 1.5),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Accent.red, width: 1.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Accent.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.sm),
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: Space.lg,
          vertical: Space.md,
        ),
        decoration: BoxDecoration(
          color: selected ? Accent.redWash : Paper.sheet,
          borderRadius: BorderRadius.circular(Radii.sm),
          border: Border.all(
            color: selected ? Accent.redLine : Paper.ruleStrong,
          ),
        ),
        child: Text(
          label,
          style: Sans.body.copyWith(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Accent.red : Pen.primary,
          ),
        ),
      ),
    );
  }
}

// ── Aperçu en direct ─────────────────────────────────────────────────────

/// Le CV en construction, avec des barres grises là où l'information manque.
///
/// Ce squelette est le ressort de l'écran : il montre ce qui reste à remplir
/// sans l'énumérer, et rend visible l'effet de chaque frappe.
class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.data});

  final CvData data;

  @override
  Widget build(BuildContext context) {
    final info = data.personalInfo;
    final exp = data.experiences.firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.xs),
        boxShadow: Shadow.sheet,
      ),
      padding: const EdgeInsets.all(Space.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (info.fullName.trim().isEmpty)
            const _Skeleton(width: 0.55, height: 18)
          else
            Text(info.fullName, style: Serif.name.copyWith(fontSize: 20)),
          const SizedBox(height: Space.xs),
          if (info.jobTitle.trim().isEmpty)
            const _Skeleton(width: 0.35, height: 9)
          else
            Text(info.jobTitle.toUpperCase(), style: Mono.overlineAccent),
          const SizedBox(height: Space.md),
          const Divider(color: Paper.rule, height: 1),
          const SizedBox(height: Space.md),
          const Text('EXPÉRIENCE', style: Mono.overline),
          const SizedBox(height: Space.sm),
          if (exp == null || _line(exp).isEmpty)
            const _Skeleton(width: 0.7, height: 8)
          else
            Text(_line(exp), style: Sans.entryTitle),
          const SizedBox(height: Space.sm),
          if (exp == null || exp.description.trim().isEmpty) ...[
            const _Skeleton(width: 0.95, height: 6),
            const SizedBox(height: 5),
            const _Skeleton(width: 0.8, height: 6),
            const SizedBox(height: 5),
            const _Skeleton(width: 0.6, height: 6),
          ] else
            Text(exp.description, style: Sans.sheetBody),
          if (data.skills.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            const Text('COMPÉTENCES', style: Mono.overline),
            const SizedBox(height: Space.xs),
            Text(
              data.skills.map((s) => s.name).join(' · '),
              style: Sans.sheetBody,
            ),
          ],
        ],
      ),
    );
  }

  String _line(Experience e) =>
      [e.position, e.company].where((s) => s.trim().isNotEmpty).join(' — ');
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: width,
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Paper.rule,
          borderRadius: BorderRadius.circular(Radii.xs),
        ),
      ),
    );
  }
}
