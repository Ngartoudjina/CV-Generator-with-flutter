import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cv_data.dart';
import '../../state/cv_model.dart';
import '../../theme/colors.dart';
import '../../widgets/cv_text_field.dart';

/// Port de `ui/screens/ExperienceScreen.kt`.
class ExperienceScreen extends StatefulWidget {
  const ExperienceScreen({super.key});

  @override
  State<ExperienceScreen> createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  late bool _showForm;

  @override
  void initState() {
    super.initState();
    // `read` et non `watch` : on ne lit l'état initial qu'une fois, comme le
    // `remember { mutableStateOf(cvData.experiences.isEmpty()) }` de Compose.
    _showForm = context.read<CvModel>().cvData.experiences.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final experiences = model.cvData.experiences;
    final showForm = _showForm;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Expériences professionnelles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          for (final exp in experiences) ...[
            ExperienceCard(
              exp: exp,
              onDelete: () => model.removeExperience(exp.id),
            ),
            const SizedBox(height: 16),
          ],
          if (showForm)
            ExperienceForm(
              onSave: (exp) {
                model.addExperience(exp);
                setState(() => _showForm = false);
              },
              onCancel: () => setState(() => _showForm = false),
            )
          else
            OutlinedButton.icon(
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.add, color: AppColors.gold),
              label: const Text(
                'Ajouter une expérience',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class ExperienceCard extends StatelessWidget {
  const ExperienceCard({super.key, required this.exp, required this.onDelete});

  final Experience exp;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: AppColors.mediumGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    exp.position,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                  Text(
                    exp.company,
                    style: TextStyle(fontSize: 14, color: scheme.onSurface),
                  ),
                  Text(
                    '${exp.startDate} — ${exp.isCurrent ? "Présent" : exp.endDate}',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Supprimer',
              icon: Icon(Icons.delete, color: scheme.error),
            ),
          ],
        ),
      ),
    );
  }
}

class ExperienceForm extends StatefulWidget {
  const ExperienceForm({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  final ValueChanged<Experience> onSave;
  final VoidCallback onCancel;

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  String _company = '';
  String _position = '';
  String _startDate = '';
  String _endDate = '';
  bool _isCurrent = false;
  String _description = '';

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
            'Nouvelle expérience',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 12),
          // Clés explicites : cocher « Poste actuel » retire le champ « Date
          // fin » du milieu de la colonne. Sans clé, Flutter réapparie les
          // widgets par position et l'état du champ retiré migrerait vers le
          // suivant — le texte de « Date fin » atterrirait dans « Description ».
          CvTextField(
            key: const ValueKey('exp_position'),
            value: _position,
            label: 'Poste *',
            onChanged: (v) => _position = v,
          ),
          const SizedBox(height: 12),
          CvTextField(
            key: const ValueKey('exp_company'),
            value: _company,
            label: 'Entreprise *',
            onChanged: (v) => _company = v,
          ),
          const SizedBox(height: 12),
          CvTextField(
            key: const ValueKey('exp_start'),
            value: _startDate,
            label: 'Date début (ex: Jan 2022)',
            onChanged: (v) => _startDate = v,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _isCurrent,
                activeColor: AppColors.gold,
                onChanged: (v) => setState(() => _isCurrent = v ?? false),
              ),
              const Text('Poste actuel', style: TextStyle(fontSize: 14)),
            ],
          ),
          if (!_isCurrent) ...[
            const SizedBox(height: 12),
            CvTextField(
              key: const ValueKey('exp_end'),
              value: _endDate,
              label: 'Date fin (ex: Déc 2023)',
              onChanged: (v) => _endDate = v,
            ),
          ],
          const SizedBox(height: 12),
          CvTextField(
            key: const ValueKey('exp_description'),
            value: _description,
            label: 'Description',
            minLines: 3,
            maxLines: 5,
            onChanged: (v) => _description = v,
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
                    if (_position.isNotEmpty && _company.isNotEmpty) {
                      widget.onSave(
                        Experience(
                          company: _company,
                          position: _position,
                          startDate: _startDate,
                          endDate: _endDate,
                          isCurrent: _isCurrent,
                          description: _description,
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
