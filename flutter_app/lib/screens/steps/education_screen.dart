import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cv_data.dart';
import '../../state/cv_model.dart';
import '../../theme/colors.dart';
import '../../widgets/cv_text_field.dart';

/// Port de `ui/screens/EducationScreen.kt`.
class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  late bool _showForm;

  @override
  void initState() {
    super.initState();
    _showForm = context.read<CvModel>().cvData.educations.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final scheme = Theme.of(context).colorScheme;
    final educations = model.cvData.educations;
    final showForm = _showForm;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Formation',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          for (final edu in educations) ...[
            Card(
              color: AppColors.mediumGray,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            edu.degree,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                          Text(edu.school,
                              style: const TextStyle(fontSize: 14)),
                          if (edu.field.isNotEmpty)
                            Text(
                              edu.field,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          Text(
                            '${edu.startYear} — ${edu.endYear}',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => model.removeEducation(edu.id),
                      icon: Icon(Icons.delete, color: scheme.error),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (showForm)
            EducationForm(
              onSave: (edu) {
                model.addEducation(edu);
                setState(() => _showForm = false);
              },
              onCancel: () => setState(() => _showForm = false),
            )
          else
            OutlinedButton.icon(
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.add, color: AppColors.gold),
              label: const Text(
                'Ajouter une formation',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class EducationForm extends StatefulWidget {
  const EducationForm({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  final ValueChanged<Education> onSave;
  final VoidCallback onCancel;

  @override
  State<EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  String _school = '';
  String _degree = '';
  String _field = '';
  String _startYear = '';
  String _endYear = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.mediumGray,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nouvelle formation',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          CvTextField(
            value: _degree,
            label: 'Diplôme *',
            onChanged: (v) => _degree = v,
          ),
          const SizedBox(height: 12),
          CvTextField(
            value: _school,
            label: 'École / Université *',
            onChanged: (v) => _school = v,
          ),
          const SizedBox(height: 12),
          CvTextField(
            value: _field,
            label: 'Domaine / Spécialité',
            onChanged: (v) => _field = v,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CvTextField(
                  value: _startYear,
                  label: 'Année début',
                  onChanged: (v) => _startYear = v,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CvTextField(
                  value: _endYear,
                  label: 'Année fin',
                  onChanged: (v) => _endYear = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: scheme.onPrimary,
                  ),
                  onPressed: () {
                    if (_degree.isNotEmpty && _school.isNotEmpty) {
                      widget.onSave(
                        Education(
                          school: _school,
                          degree: _degree,
                          field: _field,
                          startYear: _startYear,
                          endYear: _endYear,
                        ),
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
