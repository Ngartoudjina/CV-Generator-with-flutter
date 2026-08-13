import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cv_data.dart';
import '../../state/cv_model.dart';
import '../../theme/colors.dart';
import '../../widgets/cv_text_field.dart';

/// Port de `ui/screens/PersonalInfoScreen.kt`.
class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CvModel>();
    final info = model.cvData.personalInfo;

    void save(PersonalInfo next) => model.updatePersonalInfo(next);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),
          CvTextField(
            value: info.fullName,
            label: 'Nom complet *',
            onChanged: (v) => save(info.copyWith(fullName: v)),
          ),
          const SizedBox(height: 16),
          CvTextField(
            value: info.jobTitle,
            label: 'Titre / Poste visé *',
            onChanged: (v) => save(info.copyWith(jobTitle: v)),
          ),
          const SizedBox(height: 16),
          CvTextField(
            value: info.email,
            label: 'Email *',
            onChanged: (v) => save(info.copyWith(email: v)),
          ),
          const SizedBox(height: 16),
          CvTextField(
            value: info.phone,
            label: 'Téléphone',
            onChanged: (v) => save(info.copyWith(phone: v)),
          ),
          const SizedBox(height: 16),
          CvTextField(
            value: info.city,
            label: 'Ville / Pays',
            onChanged: (v) => save(info.copyWith(city: v)),
          ),
          const SizedBox(height: 16),
          CvTextField(
            value: info.linkedIn,
            label: 'LinkedIn (optionnel)',
            onChanged: (v) => save(info.copyWith(linkedIn: v)),
          ),
          const SizedBox(height: 16),
          CvTextField(
            value: info.summary,
            label: 'Résumé professionnel',
            minLines: 4,
            maxLines: 6,
            onChanged: (v) => save(info.copyWith(summary: v)),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
