import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cv_data.dart';
import '../models/cv_section.dart';
import '../state/cv_model.dart';
import '../theme/design_tokens.dart';

/// Champs d'édition, un jeu par section — le contenu déplié de
/// `maquettes/05_editeur.jpg`.
///
/// Chaque entrée d'une liste (expérience, formation, langue) porte ses propres
/// contrôleurs dans son widget, identifié par la clé de l'entrée. C'est ce qui
/// permet d'en éditer plusieurs : le portage n'affichait que la première et
/// perdait les autres.
class SectionEditor extends StatelessWidget {
  const SectionEditor({
    super.key,
    required this.section,
    required this.onPropose,
  });

  final CvSection section;
  final VoidCallback onPropose;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final data = model.cvData;

    return switch (section) {
      CvSection.profil => _ProfilEditor(model: model),
      CvSection.contact => _ContactEditor(model: model),
      CvSection.experience => _ListEditor(
          entries: [
            for (final e in data.experiences)
              _ExperienceEntry(key: ValueKey(e.id), model: model, entry: e),
          ],
          addLabel: 'Ajouter une expérience',
          onAdd: () => model.addExperience(Experience()),
          onPropose: onPropose,
        ),
      CvSection.formation => _ListEditor(
          entries: [
            for (final e in data.educations)
              _EducationEntry(key: ValueKey(e.id), model: model, entry: e),
          ],
          addLabel: 'Ajouter une formation',
          onAdd: () => model.addEducation(Education()),
        ),
      CvSection.langues => _ListEditor(
          entries: [
            for (final l in data.languages)
              _LanguageEntry(key: ValueKey(l.id), model: model, entry: l),
          ],
          addLabel: 'Ajouter une langue',
          onAdd: () => model.addLanguage(Language()),
        ),
      CvSection.competences => _SkillsEditor(model: model),
    };
  }
}

// ── Cadre commun ─────────────────────────────────────────────────────────

class _ListEditor extends StatelessWidget {
  const _ListEditor({
    required this.entries,
    required this.addLabel,
    required this.onAdd,
    this.onPropose,
  });

  final List<Widget> entries;
  final String addLabel;
  final VoidCallback onAdd;
  final VoidCallback? onPropose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...entries,
        if (onPropose != null) ...[
          _GhostButton(
            label: "Proposer une reformulation",
            icon: Icons.auto_awesome,
            accent: true,
            onTap: onPropose!,
          ),
          const SizedBox(height: Space.sm),
        ],
        _GhostButton(label: addLabel, icon: Icons.add, onTap: onAdd),
      ],
    );
  }
}

/// Cadre d'une entrée : fond blanc sur le lavis rouge de la section ouverte,
/// avec le bouton de suppression en tête.
class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.children,
    required this.onDelete,
    this.title,
  });

  final List<Widget> children;
  final VoidCallback onDelete;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Space.md),
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: Paper.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title ?? '', style: Mono.overline),
              ),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(Radii.xs),
                child: const Padding(
                  padding: EdgeInsets.all(Space.xs),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Pen.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          ...children,
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ? Accent.red : Pen.secondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Space.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: accent ? Accent.redLine : Paper.ruleStrong,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: Space.sm),
            Text(
              label,
              style: Sans.button.copyWith(fontSize: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profil & contact ─────────────────────────────────────────────────────

class _ProfilEditor extends StatelessWidget {
  const _ProfilEditor({required this.model});

  final CvModel model;

  @override
  Widget build(BuildContext context) {
    final info = model.cvData.personalInfo;

    return Column(
      children: [
        EditorField(
          key: const ValueKey('profil_name'),
          label: 'Nom complet',
          initial: info.fullName,
          onChanged: (v) =>
              model.updatePersonalInfo(info.copyWith(fullName: v)),
        ),
        const SizedBox(height: Space.md),
        EditorField(
          key: const ValueKey('profil_job'),
          label: 'Titre professionnel',
          initial: info.jobTitle,
          onChanged: (v) =>
              model.updatePersonalInfo(info.copyWith(jobTitle: v)),
        ),
        const SizedBox(height: Space.md),
        EditorField(
          key: const ValueKey('profil_summary'),
          label: 'Résumé',
          initial: info.summary,
          maxLines: 4,
          onChanged: (v) => model.updatePersonalInfo(info.copyWith(summary: v)),
        ),
      ],
    );
  }
}

class _ContactEditor extends StatelessWidget {
  const _ContactEditor({required this.model});

  final CvModel model;

  @override
  Widget build(BuildContext context) {
    final info = model.cvData.personalInfo;

    return Column(
      children: [
        EditorField(
          key: const ValueKey('contact_email'),
          label: 'Email',
          initial: info.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => model.updatePersonalInfo(info.copyWith(email: v)),
        ),
        const SizedBox(height: Space.md),
        EditorField(
          key: const ValueKey('contact_phone'),
          label: 'Téléphone',
          initial: info.phone,
          keyboardType: TextInputType.phone,
          onChanged: (v) => model.updatePersonalInfo(info.copyWith(phone: v)),
        ),
        const SizedBox(height: Space.md),
        EditorField(
          key: const ValueKey('contact_city'),
          label: 'Ville',
          initial: info.city,
          onChanged: (v) => model.updatePersonalInfo(info.copyWith(city: v)),
        ),
        const SizedBox(height: Space.md),
        EditorField(
          key: const ValueKey('contact_linkedin'),
          label: 'LinkedIn',
          initial: info.linkedIn,
          onChanged: (v) =>
              model.updatePersonalInfo(info.copyWith(linkedIn: v)),
        ),
      ],
    );
  }
}

// ── Entrées de liste ─────────────────────────────────────────────────────

class _ExperienceEntry extends StatelessWidget {
  const _ExperienceEntry({
    super.key,
    required this.model,
    required this.entry,
  });

  final CvModel model;
  final Experience entry;

  @override
  Widget build(BuildContext context) {
    void update(Experience e) => model.updateExperience(e);

    return _EntryCard(
      title: entry.position.trim().isEmpty
          ? 'NOUVELLE EXPÉRIENCE'
          : entry.position.toUpperCase(),
      onDelete: () => model.removeExperience(entry.id),
      children: [
        EditorField(
          label: 'Poste',
          initial: entry.position,
          onChanged: (v) => update(entry.copyWith(position: v)),
        ),
        const SizedBox(height: Space.md),
        EditorField(
          label: 'Entreprise',
          initial: entry.company,
          onChanged: (v) => update(entry.copyWith(company: v)),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: EditorField(
                label: 'Début',
                initial: entry.startDate,
                onChanged: (v) => update(entry.copyWith(startDate: v)),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: EditorField(
                label: 'Fin',
                initial: entry.endDate,
                onChanged: (v) => update(entry.copyWith(endDate: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        EditorField(
          label: 'Description',
          initial: entry.description,
          maxLines: 4,
          onChanged: (v) => update(entry.copyWith(description: v)),
        ),
      ],
    );
  }
}

class _EducationEntry extends StatelessWidget {
  const _EducationEntry({
    super.key,
    required this.model,
    required this.entry,
  });

  final CvModel model;
  final Education entry;

  @override
  Widget build(BuildContext context) {
    void update(Education e) => model.updateEducation(e);

    return _EntryCard(
      title: entry.degree.trim().isEmpty
          ? 'NOUVELLE FORMATION'
          : entry.degree.toUpperCase(),
      onDelete: () => model.removeEducation(entry.id),
      children: [
        EditorField(
          label: 'Diplôme',
          initial: entry.degree,
          onChanged: (v) => update(entry.copyWith(degree: v)),
        ),
        const SizedBox(height: Space.md),
        EditorField(
          label: 'Établissement',
          initial: entry.school,
          onChanged: (v) => update(entry.copyWith(school: v)),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: EditorField(
                label: 'Début',
                initial: entry.startYear,
                onChanged: (v) => update(entry.copyWith(startYear: v)),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: EditorField(
                label: 'Fin',
                initial: entry.endYear,
                onChanged: (v) => update(entry.copyWith(endYear: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageEntry extends StatelessWidget {
  const _LanguageEntry({
    super.key,
    required this.model,
    required this.entry,
  });

  final CvModel model;
  final Language entry;

  @override
  Widget build(BuildContext context) {
    return _EntryCard(
      title: entry.name.trim().isEmpty
          ? 'NOUVELLE LANGUE'
          : entry.name.toUpperCase(),
      onDelete: () => model.removeLanguage(entry.id),
      children: [
        Row(
          children: [
            Expanded(
              child: EditorField(
                label: 'Langue',
                initial: entry.name,
                onChanged: (v) => model.updateLanguage(entry.copyWith(name: v)),
              ),
            ),
            const SizedBox(width: Space.md),
            Expanded(
              child: EditorField(
                label: 'Niveau',
                initial: entry.level,
                onChanged: (v) =>
                    model.updateLanguage(entry.copyWith(level: v)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Compétences ──────────────────────────────────────────────────────────

class _SkillsEditor extends StatefulWidget {
  const _SkillsEditor({required this.model});

  final CvModel model;

  @override
  State<_SkillsEditor> createState() => _SkillsEditorState();
}

class _SkillsEditorState extends State<_SkillsEditor> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final exists = widget.model.cvData.skills
        .any((s) => s.name.toLowerCase() == name.toLowerCase());
    if (!exists) widget.model.addSkill(Skill(name: name));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final skills = widget.model.cvData.skills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (skills.isNotEmpty) ...[
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.sm,
            children: [
              for (final s in skills)
                _SkillChip(
                  label: s.name,
                  onRemove: () => widget.model.removeSkill(s.id),
                ),
            ],
          ),
          const SizedBox(height: Space.lg),
        ],
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onSubmitted: (_) => _add(),
                decoration: const InputDecoration(
                  hintText: 'Ajouter une compétence',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: Space.md),
            IconButton(
              onPressed: _add,
              icon: const Icon(Icons.add, color: Accent.red),
            ),
          ],
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.xs),
        border: Border.all(color: Paper.ruleStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Sans.sheetBody.copyWith(
              color: Pen.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: Space.sm),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Pen.muted),
          ),
        ],
      ),
    );
  }
}

// ── Champ ────────────────────────────────────────────────────────────────

/// Champ de saisie de l'éditeur.
///
/// Le contrôleur est interne et amorcé une seule fois : relire le modèle à
/// chaque frappe replacerait le curseur en début de texte. La clé de l'entrée
/// garantit qu'un champ ne récupère pas l'état de son voisin lorsqu'une entrée
/// est supprimée au milieu d'une liste.
class EditorField extends StatefulWidget {
  const EditorField({
    super.key,
    required this.label,
    required this.initial,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final String initial;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  State<EditorField> createState() => _EditorFieldState();
}

class _EditorFieldState extends State<EditorField> {
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
        Text(widget.label.toUpperCase(), style: Mono.overline),
        const SizedBox(height: Space.xs),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          minLines: widget.maxLines > 1 ? 3 : 1,
          keyboardType: widget.keyboardType,
          style: Sans.body.copyWith(color: Pen.primary, fontSize: 14),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }
}
