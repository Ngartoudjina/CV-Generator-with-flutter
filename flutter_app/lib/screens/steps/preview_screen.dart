import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cv_data.dart';
import '../../state/cv_model.dart';
import '../../theme/colors.dart';

/// Port de `ui/screens/PreviewScreen.kt` — rendu écran du CV « papier ».
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key, required this.onExportPdf});

  final VoidCallback onExportPdf;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<CvModel>().cvData;
    final info = data.personalInfo;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte blanche simulant une A4
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Bloc en-tête
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.deepBlack,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.fullName.isEmpty ? 'Votre Nom' : info.fullName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.cream,
                        ),
                      ),
                      Text(
                        info.jobTitle.isEmpty
                            ? 'Titre professionnel'
                            : info.jobTitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        children: [
                          if (info.email.isNotEmpty) _CvChip(info.email),
                          if (info.phone.isNotEmpty) _CvChip(info.phone),
                          if (info.city.isNotEmpty) _CvChip(info.city),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (info.summary.isNotEmpty)
                  _CvSection(
                    title: 'Profil',
                    child: Text(
                      info.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF333333),
                        height: 1.54,
                      ),
                    ),
                  ),

                if (data.experiences.isNotEmpty)
                  _CvSection(
                    title: 'Expériences',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final exp in data.experiences)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        exp.position,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppColors.deepBlack,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      exp.period,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  exp.company,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444444),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (exp.description.isNotEmpty)
                                  Text(
                                    exp.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF555555),
                                      height: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                if (data.educations.isNotEmpty)
                  _CvSection(
                    title: 'Formation',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final edu in data.educations)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        edu.degree,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          color: AppColors.deepBlack,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      edu.years,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF666666),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  edu.school,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF444444),
                                  ),
                                ),
                                if (edu.field.isNotEmpty)
                                  Text(
                                    edu.field,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF666666),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                if (data.skills.isNotEmpty)
                  _CvSection(
                    title: 'Compétences',
                    child: Column(
                      children: [
                        for (final row in _chunked(data.skills, 2))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                for (final skill in row) ...[
                                  Expanded(child: _SkillBar(skill: skill)),
                                  const SizedBox(width: 12),
                                ],
                                if (row.length == 1) const Spacer(),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                if (data.languages.isNotEmpty)
                  _CvSection(
                    title: 'Langues',
                    child: Wrap(
                      spacing: 16,
                      children: [
                        for (final lang in data.languages)
                          Text(
                            '${lang.name} · ${lang.level}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF444444),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.deepBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onExportPdf,
                child: const Text(
                  'Exporter en PDF',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

List<List<T>> _chunked<T>(List<T> list, int size) {
  return [
    for (var i = 0; i < list.length; i += size)
      list.sublist(i, (i + size).clamp(0, list.length)),
  ];
}

class _CvSection extends StatelessWidget {
  const _CvSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC8A96E),
              letterSpacing: 2,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFC8A96E)),
          ),
          child,
        ],
      ),
    );
  }
}

class _CvChip extends StatelessWidget {
  const _CvChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, color: Color(0xFFCCCCCC)),
    );
  }
}

class _SkillBar extends StatelessWidget {
  const _SkillBar({required this.skill});

  final Skill skill;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                skill.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF333333),
                ),
              ),
            ),
            Text(
              skill.level.label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
            ),
          ],
        ),
        const SizedBox(height: 3),
        LinearProgressIndicator(
          value: skill.level.value,
          minHeight: 3,
          color: const Color(0xFFC8A96E),
          backgroundColor: const Color(0xFFDDDDDD),
        ),
      ],
    );
  }
}
