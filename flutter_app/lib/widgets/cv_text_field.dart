import 'package:flutter/material.dart';

import '../theme/colors.dart';

/// Port des deux surcharges `CvTextField` déclarées dans
/// `PersonalInfoScreen.kt` et `EducationScreen.kt` — fusionnées ici en un
/// seul widget (Dart n'a pas de surcharge de fonctions).
class CvTextField extends StatelessWidget {
  const CvTextField({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String value;
  final String label;
  final ValueChanged<String> onChanged;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: false,
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gold, width: 2),
        ),
        floatingLabelStyle: const TextStyle(color: AppColors.gold),
      ),
    );
  }
}
