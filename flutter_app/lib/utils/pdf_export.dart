import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cv_data.dart';
import '../models/cv_font.dart';
import '../pdf/pdf_generator.dart';

/// Génère le PDF et le remet au sélecteur de partage système. Factorisé ici
/// parce que deux écrans l'appellent : l'éditeur (`EditorScreen`) et
/// l'assistant (`CvWizardScreen`).
///
/// Remplace `MainActivity.exportPdf()` : côté Android c'était `FileProvider`
/// + `Intent.ACTION_VIEW` + `Toast`, ce qui exigeait de déclarer un provider
/// dans le manifeste. `Printing.sharePdf` couvre Android, iOS et le web sans
/// configuration ni écriture sur disque.
Future<void> exportCvPdf(
  BuildContext context,
  CvData cvData, {
  CvFont font = CvFont.inter,
}) async {
  // Capturé avant tout `await` : le contexte peut être démonté entre-temps.
  final messenger = ScaffoldMessenger.of(context);

  try {
    // La police du document est chargée ici, et non dans PdfGenerator, pour
    // que celui-ci reste exécutable en Dart pur — sans dépendance à Flutter.
    final data = await rootBundle.load(font.asset);
    final bytes = await PdfGenerator.build(cvData, base: pw.Font.ttf(data));
    final name = PdfGenerator.fileName(cvData);

    await Printing.sharePdf(bytes: bytes, filename: name);

    messenger.showSnackBar(SnackBar(content: Text('CV exporté : $name')));
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text("Erreur lors de l'export : $e")),
    );
  }
}
