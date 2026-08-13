import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cv_data.dart';
import '../../state/cv_model.dart';
import '../../theme/colors.dart';

/// Port de `ui/screens/SkillsScreen.kt`.
class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final _skillNameCtrl = TextEditingController();
  final _langNameCtrl = TextEditingController();
  final _langLevelCtrl = TextEditingController();
  SkillLevel _skillLevel = SkillLevel.intermediate;

  @override
  void dispose() {
    _skillNameCtrl.dispose();
    _langNameCtrl.dispose();
    _langLevelCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final scheme = Theme.of(context).colorScheme;
    final data = model.cvData;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Compétences & Langues',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Compétences',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 20),

          for (final skill in data.skills)
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              skill.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              skill.level.label,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: skill.level.value,
                        minHeight: 4,
                        color: AppColors.gold,
                        backgroundColor: AppColors.mediumGray,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => model.removeSkill(skill.id),
                  icon: Icon(Icons.close, size: 16, color: scheme.error),
                ),
              ],
            ),

          const SizedBox(height: 20),

          // Formulaire d'ajout de compétence
          Container(
            decoration: BoxDecoration(
              color: AppColors.mediumGray,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ajouter une compétence',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _skillNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Compétence',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Niveau :', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final level in SkillLevel.values)
                      FilterChip(
                        selected: _skillLevel == level,
                        onSelected: (_) =>
                            setState(() => _skillLevel = level),
                        label: Text(
                          level.label,
                          style: const TextStyle(fontSize: 11),
                        ),
                        selectedColor: AppColors.gold,
                        labelStyle: TextStyle(
                          color: _skillLevel == level
                              ? scheme.onPrimary
                              : scheme.onSurface,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: scheme.onPrimary,
                  ),
                  onPressed: () {
                    if (_skillNameCtrl.text.trim().isNotEmpty) {
                      model.addSkill(
                        Skill(
                          name: _skillNameCtrl.text.trim(),
                          level: _skillLevel,
                        ),
                      );
                      _skillNameCtrl.clear();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.mediumGray),
          const SizedBox(height: 20),

          const Text(
            'Langues',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 20),

          for (final lang in data.languages)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lang.name} — ${lang.level}',
                  style: const TextStyle(fontSize: 14),
                ),
                IconButton(
                  onPressed: () => model.removeLanguage(lang.id),
                  icon: Icon(Icons.close, size: 16, color: scheme.error),
                ),
              ],
            ),

          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: AppColors.mediumGray,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ajouter une langue',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _langNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Langue (ex: Français)',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _langLevelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Niveau (ex: Natif, Courant, B2)',
                    filled: false,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: scheme.onPrimary,
                  ),
                  onPressed: () {
                    final name = _langNameCtrl.text.trim();
                    final level = _langLevelCtrl.text.trim();
                    if (name.isNotEmpty && level.isNotEmpty) {
                      model.addLanguage(Language(name: name, level: level));
                      _langNameCtrl.clear();
                      _langLevelCtrl.clear();
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
