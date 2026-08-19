import 'package:flutter/material.dart';

import '../models/ats_report.dart';
import '../models/cv_data.dart';
import '../models/cv_font.dart';
import '../theme/design_tokens.dart';
import '../widgets/cv_sheet.dart';

/// Aperçu et export — `maquettes/06_apercu-export.jpg`.
///
/// La maquette 06 est la seule des neuf à être composée en violet sur fond
/// gris ; les huit autres sont en rouge sur crème. C'est vraisemblablement un
/// reste de la direction précédente. On en reprend donc la **structure**, avec
/// la palette du reste de l'application.
///
/// L'écran affiche trois choses : le document tel qu'il sera exporté, ses
/// caractéristiques réelles (pages, poids), et le contrôle ATS.
class PreviewExportScreen extends StatelessWidget {
  const PreviewExportScreen({
    super.key,
    required this.data,
    required this.font,
    required this.report,
    required this.pageCount,
    required this.byteSize,
    required this.onClose,
    required this.onExport,
    required this.onDefineOffer,
  });

  final CvData data;
  final CvFont font;
  final AtsReport report;

  /// Nombre de pages et poids du PDF **réellement généré** — pas une
  /// estimation. La maquette affiche « PAGE 1 SUR 1 · A4 · 148 KO » ; ces
  /// valeurs sont lues dans le document produit.
  final int pageCount;
  final int byteSize;

  final VoidCallback onClose;
  final VoidCallback onExport;
  final VoidCallback onDefineOffer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paper.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close, size: 24, color: Pen.primary),
                  ),
                  Expanded(
                    child: Text(
                      'APERÇU',
                      textAlign: TextAlign.center,
                      style: Mono.overline.copyWith(letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Document ──────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Space.xxxl,
                  Space.md,
                  Space.xxxl,
                  Space.lg,
                ),
                children: [
                  CvSheet(data: data, font: font),
                  const SizedBox(height: Space.lg),
                  Text(
                    'PAGE $pageCount SUR $pageCount · A4 · '
                    '${(byteSize / 1024).round()} KO',
                    textAlign: TextAlign.center,
                    style: Mono.overline,
                  ),
                ],
              ),
            ),

            // ── Contrôle ATS ──────────────────────────────────
            _AtsSheet(
              report: report,
              onExport: onExport,
              onDefineOffer: onDefineOffer,
            ),
          ],
        ),
      ),
    );
  }
}

class _AtsSheet extends StatelessWidget {
  const _AtsSheet({
    required this.report,
    required this.onExport,
    required this.onDefineOffer,
  });

  final AtsReport report;
  final VoidCallback onExport;
  final VoidCallback onDefineOffer;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.52,
      ),
      decoration: const BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
        boxShadow: [
          BoxShadow(
            color: Color(0x141A1714),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: Space.md),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Paper.ruleStrong,
              borderRadius: BorderRadius.circular(Radii.full),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xl,
              Space.lg,
              Space.xl,
              Space.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('CONTRÔLE ATS', style: Mono.overline),
                const Spacer(),
                Text(
                  '${report.score}',
                  style: Mono.score.copyWith(
                    fontSize: 26,
                    color: Accent.red,
                  ),
                ),
                Text(
                  ' / 100',
                  style: Mono.score.copyWith(
                    fontSize: 15,
                    color: Pen.muted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Paper.rule, height: 1),
          Flexible(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (final check in report.checks) ...[
                  _CheckRow(check: check, onAction: onDefineOffer),
                  const Divider(color: Paper.rule, height: 1),
                ],
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    Space.xl,
                    Space.lg,
                    Space.xl,
                    MediaQuery.of(context).padding.bottom + Space.lg,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Radii.md),
                      boxShadow: Shadow.floating,
                    ),
                    child: FilledButton(
                      onPressed: onExport,
                      child: const Text('Télécharger le PDF'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check, required this.onAction});

  final AtsCheck check;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (check.status) {
      AtsStatus.ok => (Icons.check, Status.okFg),
      AtsStatus.warning => (Icons.warning_amber_rounded, Status.warnFg),
      AtsStatus.unavailable => (Icons.remove, Pen.faint),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.xl,
        vertical: Space.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: Space.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  check.label,
                  style: Sans.itemTitle.copyWith(
                    fontSize: 15.5,
                    color: check.status == AtsStatus.unavailable
                        ? Pen.secondary
                        : Pen.primary,
                  ),
                ),
                if (check.hint != null) ...[
                  const SizedBox(height: 2),
                  Text(check.hint!, style: Sans.body.copyWith(fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(width: Space.md),
          // Une vérification indisponible propose l'action qui la débloque,
          // plutôt qu'un verdict qu'on ne peut pas rendre.
          if (check.status == AtsStatus.unavailable)
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: const Text('DÉFINIR', style: Mono.overlineAccent),
            )
          else
            Text(
              check.detail,
              style: Mono.overline.copyWith(
                color: check.status == AtsStatus.ok ? Status.okFg : Pen.muted,
              ),
            ),
        ],
      ),
    );
  }
}
