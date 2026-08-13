import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cv_library.dart';
import '../theme/colors.dart';
import '../utils/anim.dart';

/// Onglet Profil du tableau de bord.
///
/// N'existe pas dans le projet Kotlin : `DashboardScreen.kt` déclarait
/// l'onglet et le bouton avatar (`onProfile`), mais les deux ne menaient
/// nulle part — `MainActivity` passait un lambda vide.
///
/// L'application n'a pas de compte utilisateur (`AuthScreen` accepte
/// n'importe quoi et se contente d'écrire un booléen). L'identité affichée
/// est donc dérivée des CV enregistrés, ce qui reste honnête tant qu'il n'y a
/// pas de backend.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.onSignOut,
    required this.onReplayOnboarding,
  });

  final VoidCallback onSignOut;
  final VoidCallback onReplayOnboarding;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<CvLibrary>();
    final documents = library.sortedByDate;

    final info = documents.isEmpty ? null : documents.first.data.personalInfo;
    final name =
        (info?.fullName.trim().isNotEmpty ?? false) ? info!.fullName : 'Profil';
    final email = (info?.email.trim().isNotEmpty ?? false)
        ? info!.email
        : 'Aucune adresse renseignée';

    final best = documents.isEmpty
        ? 0
        : documents.map((d) => d.score).reduce((a, b) => a > b ? a : b);
    final drafts = documents.where((d) => d.isDraft).length;

    return ListView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 120,
      ),
      children: [
        _Identity(name: name, email: email),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: _StatTile(value: '${documents.length}', label: 'CV'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(value: '$best', label: 'Meilleur score'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  value: '$drafts',
                  label: drafts > 1 ? 'Brouillons' : 'Brouillon',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _SectionLabel('Compte'),
        _ActionTile(
          icon: Icons.replay,
          label: "Revoir l'introduction",
          subtitle: 'Réaffiche les écrans de présentation au prochain accès',
          onTap: onReplayOnboarding,
        ),
        _ActionTile(
          icon: Icons.logout,
          label: 'Se déconnecter',
          subtitle: 'Vos CV enregistrés sont conservés sur cet appareil',
          onTap: onSignOut,
        ),
        const SizedBox(height: 20),
        const _SectionLabel('À propos'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Les CV sont enregistrés sur cet appareil uniquement. Il n'y a ni "
            'compte ni synchronisation : l\'écran de connexion ne vérifie rien '
            'pour l\'instant.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.appInk.withValues(alpha: 0.55),
            ),
          ),
        ),
      ],
    );
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

    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.accentCoGradient,
          ),
          child: Text(
            initials.isEmpty ? '?' : initials,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.appInk,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          email,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.appInk.withValues(alpha: 0.50),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.appInk.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          GradientText(
            value,
            gradient: AppColors.accentCoGradient,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: AppColors.appInk.withValues(alpha: 0.50),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10.5,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
          color: AppColors.appInk.withValues(alpha: 0.38),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: PressScale(
        pressedScale: 0.98,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.appCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.appInk.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.appInk,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.35,
                        color: AppColors.appInk.withValues(alpha: 0.48),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.appInk.withValues(alpha: 0.28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onglets déclarés par la maquette mais sans implémentation derrière.
///
/// Un onglet muet laisse croire à un bug ; on dit plutôt ce qui manque.
class ComingSoonTab extends StatelessWidget {
  const ComingSoonTab({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                icon,
                style: const TextStyle(fontSize: 26, color: AppColors.accent),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.appInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.appInk.withValues(alpha: 0.52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
