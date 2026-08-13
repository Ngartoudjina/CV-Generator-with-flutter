import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/cv_data.dart';
import '../pdf/pdf_generator.dart';

/// Génère le PDF, l'écrit sur disque puis le remet au sélecteur de partage
/// système. Factorisé ici parce que deux écrans l'appellent : l'éditeur
/// (`EditorScreen`) et l'assistant (`CvWizardScreen`).
///
/// Remplace `MainActivity.exportPdf()` : côté Android c'était `FileProvider`
/// + `Intent.ACTION_VIEW` + `Toast`, ce qui nécessitait une déclaration de
/// provider dans le manifeste. `Printing.sharePdf` couvre Android et iOS sans
/// configuration.
Future<void> exportCvPdf(BuildContext context, CvData cvData) async {
  // Capturé avant tout `await` : le contexte peut être démonté entre-temps.
  final messenger = ScaffoldMessenger.of(context);

  try {
    final file = await PdfGenerator.generate(cvData);
    final bytes = await file.readAsBytes();
    final name = file.uri.pathSegments.last;

    await Printing.sharePdf(bytes: bytes, filename: name);

    messenger.showSnackBar(SnackBar(content: Text('CV exporté : $name')));
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text("Erreur lors de l'export : $e")),
    );
  }
}
