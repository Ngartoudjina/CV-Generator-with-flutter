import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cv_font.dart';
import '../state/cv_library.dart';
import '../theme/design_tokens.dart';

/// Profil — `maquettes/08_profil.jpg`.
///
/// La maquette liste des réglages dont plusieurs n'ont rien derrière :
/// l'application n'a ni compte, ni facturation, ni notifications, ni seconde
/// langue. On en reprend la **forme** — c'est elle qui donne sa cohérence à
/// l'écran — mais chaque ligne dit la vérité : celles qui agissent agissent,
/// les autres expliquent ce qui manque au lieu de faire semblant.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onSignOut,
    required this.onReplayOnboarding,
    this.onOpenTemplates,
  });

  final VoidCallback onSignOut;
  final VoidCallback onReplayOnboarding;
  final VoidCallback? onOpenTemplates;

  /// Nombre de CV inclus dans la formule gratuite, tel que l'annonce la
  /// maquette. **Affiché, jamais appliqué** : restreindre la création
  /// supposerait une facturation, qui n'existe pas. Le jour où elle
  /// existera, c'est ici que la limite sera lue.
  static const int freeQuota = 3;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<CvLibrary>();
    final docs = library.sortedByDate;

    final info = docs.isEmpty ? null : docs.first.data.personalInfo;
    final name =
        (info?.fullName.trim().isNotEmpty ?? false) ? info!.fullName : 'Profil';
    final email = (info?.email.trim().isNotEmpty ?? false)
        ? info!.email
        : 'aucune adresse renseignée';

    final font = CvFont.fromFamily(library.current?.fontFamily);

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        _Identity(name: name, email: email),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Space.xl,
            Space.lg,
            Space.xl,
            0,
          ),
          child: _PlanCard(used: docs.length),
        ),
        const _SectionHeader(number: '01', label: 'COMPTE'),
        _Row(
          label: 'Informations personnelles',
          onTap: () => _explain(
            context,
            "L'identité affichée est reprise du CV le plus récent : "
            "l'application n'a pas de compte utilisateur.",
          ),
        ),
        _Row(
          label: 'Mot de passe',
          onTap: () => _explain(
            context,
            "Aucun mot de passe n'est enregistré : l'écran de connexion ne "
            'vérifie rien, faute de serveur.',
          ),
        ),
        const _SectionHeader(number: '02', label: 'DOCUMENTS'),
        _Row(
          label: 'Police du document',
          value: font.label,
          onTap: onOpenTemplates,
        ),
        _Row(
          label: "Format d'export",
          value: 'PDF',
          onTap: () => _explain(
            context,
            "Le PDF est le seul format produit pour l'instant. L'export DOCX "
            'que montre la maquette reste à écrire.',
          ),
        ),
        const _SectionHeader(number: '03', label: 'PRÉFÉRENCES'),
        _Row(
          label: 'Langue',
          value: 'Français',
          onTap: () => _explain(
            context,
            "L'application n'est traduite qu'en français ; les textes sont "
            'écrits en dur, sans fichiers de localisation.',
          ),
        ),
        _Row(
          label: "Revoir l'introduction",
          onTap: onReplayOnboarding,
        ),
        const SizedBox(height: Space.xxl),
        InkWell(
          onTap: onSignOut,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.xl,
              vertical: Space.lg,
            ),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Paper.rule),
                bottom: BorderSide(color: Paper.rule),
              ),
            ),
            child: Text(
              'Se déconnecter',
              style: Sans.itemTitle.copyWith(color: Accent.red),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Space.xl),
          child: Text(
            'Vos CV sont enregistrés sur cet appareil uniquement. '
            "Aucune donnée n'est envoyée ailleurs.",
            style: Sans.body.copyWith(fontSize: 13),
          ),
        ),
      ],
    );
  }

  /// Une explication brève plutôt qu'une boîte de dialogue par réglage : la
  /// raison tient en une phrase, et l'utilisateur n'a rien à valider.
  static void _explain(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.xl, Space.md, Space.xl, 0),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Pen.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials.isEmpty ? '?' : initials,
              style: Sans.button.copyWith(color: Paper.bg, fontSize: 17),
            ),
          ),
          const SizedBox(width: Space.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Serif.title.copyWith(fontSize: 26),
                ),
                // Pas de capitales ici, contrairement au reste des lignes
                // monospace : la partie locale d'une adresse est
                // sensible à la casse, et l'afficher fausse la relecture.
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Mono.overline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte de formule.
///
/// Le compteur affiche le **nombre réel** de CV, pas un « 2 / 3 » décoratif.
/// La limite, elle, n'est pas appliquée : voir [ProfileScreen.freeQuota].
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.used});

  final int used;

  @override
  Widget build(BuildContext context) {
    final ratio = (used / ProfileScreen.freeQuota).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(Space.lg),
      decoration: BoxDecoration(
        color: Paper.sheet,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: Paper.rule),
        boxShadow: Shadow.sheet,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('FORMULE GRATUITE', style: Mono.overline),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.md,
                  vertical: Space.sm,
                ),
                decoration: BoxDecoration(
                  color: Accent.redWash,
                  borderRadius: BorderRadius.circular(Radii.xs),
                ),
                child: Text(
                  '$used / ${ProfileScreen.freeQuota} CV',
                  style: Mono.badge.copyWith(color: Accent.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.full),
            child: SizedBox(
              height: 4,
              child: Stack(
                children: [
                  const Positioned.fill(child: ColoredBox(color: Paper.rule)),
                  Positioned.fill(
                    child: FractionallySizedBox(
                      widthFactor: ratio,
                      alignment: Alignment.centerLeft,
                      child: const ColoredBox(color: Accent.red),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          Row(
            children: [
              Expanded(
                child: Text(
                  "CV illimités, tous les modèles et l'export DOCX.",
                  style: Sans.body.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: Space.md),
              // La maquette met ici un bouton « Premium ». Il n'y a pas de
              // facturation : un appel à l'action qui ne mène nulle part
              // vaut moins qu'une étiquette qui dit où en est la chose.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.md,
                  vertical: Space.sm,
                ),
                decoration: BoxDecoration(
                  color: Accent.redWash,
                  borderRadius: BorderRadius.circular(Radii.xs),
                  border: Border.all(color: Accent.redLine),
                ),
                child: Text(
                  'BIENTÔT',
                  style: Mono.badge.copyWith(color: Accent.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.xl,
        Space.lg,
        Space.xl,
        Space.md,
      ),
      child: Row(
        children: [
          Text(number, style: Mono.index),
          const SizedBox(width: Space.lg),
          Text(label, style: Mono.overline),
          const SizedBox(width: Space.md),
          const Expanded(child: Divider(color: Paper.rule, height: 1)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, this.value, this.onTap});

  final String label;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Paper.rule)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xl,
          vertical: Space.lg,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: Sans.itemTitle)),
            if (value != null) ...[
              Text(value!, style: Mono.meta),
              const SizedBox(width: Space.sm),
            ],
            const Icon(Icons.chevron_right, size: 20, color: Pen.faint),
          ],
        ),
      ),
    );
  }
}
