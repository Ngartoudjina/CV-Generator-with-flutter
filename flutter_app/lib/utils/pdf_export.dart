import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/cv_data.dart';
import '../models/cv_font.dart';
import '../pdf/pdf_generator.dart';
import '../theme/design_tokens.dart';
import '../widgets/states.dart';

/// Génère le PDF et le remet au sélecteur de partage système. Factorisé ici
/// parce que deux écrans l'appellent : l'éditeur (`EditorScreen`) et
/// l'assistant (`CvWizardScreen`).
///
/// Remplace `MainActivity.exportPdf()` : côté Android c'était `FileProvider`
/// + `Intent.ACTION_VIEW` + `Toast`, ce qui exigeait de déclarer un provider
/// dans le manifeste. `Printing.sharePdf` couvre Android, iOS et le web sans
/// configuration ni écriture sur disque.
///
/// La réussite s'annonce par la feuille de la maquette 09 et non par une
/// bannière : celle-ci s'effaçait avant qu'on ait lu le nom du fichier, et ne
/// proposait rien. Le partage y est une **action**, pas un effet de bord — le
/// sélecteur système ne s'ouvre que si l'utilisateur le demande.
Future<void> exportCvPdf(
  BuildContext context,
  CvData cvData, {
  CvFont font = CvFont.inter,
}) async {
  // Capturé avant tout `await` : le contexte peut être démonté entre-temps.
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  try {
    // La police du document est chargée ici, et non dans PdfGenerator, pour
    // que celui-ci reste exécutable en Dart pur — sans dépendance à Flutter.
    final data = await rootBundle.load(font.asset);
    final bytes = await PdfGenerator.build(cvData, base: pw.Font.ttf(data));
    final name = PdfGenerator.fileName(cvData);

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Paper.sheet,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      builder: (sheetContext) => SuccessSheet(
        title: 'CV prêt',
        detail: '$name · ${(bytes.length / 1024).round()} Ko',
        onShare: () {
          Navigator.of(sheetContext).pop();
          Printing.sharePdf(bytes: bytes, filename: name);
        },
        onDone: () => Navigator.of(sheetContext).pop(),
      ),
    );
  } catch (e) {
    // `navigator` plutôt que `context` : la feuille a pu être démontée.
    if (navigator.mounted) {
      messenger.showSnackBar(
        SnackBar(content: Text("Erreur lors de l'export : $e")),
      );
    }
  }
}
