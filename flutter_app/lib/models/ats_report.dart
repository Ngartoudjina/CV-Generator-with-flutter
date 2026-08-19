import 'cv_data.dart';

/// Résultat d'un contrôle ATS — `maquettes/06_apercu-export.jpg`.
enum AtsStatus { ok, warning, unavailable }

class AtsCheck {
  const AtsCheck({
    required this.label,
    required this.status,
    required this.detail,
    this.hint,
    this.weight = 1,
  });

  final String label;
  final AtsStatus status;

  /// Valeur affichée à droite — « OK », « 14 / 15 », « À DÉFINIR ».
  final String detail;

  /// Précision sous le libellé, quand le constat mérite une explication.
  final String? hint;

  final int weight;
}

/// Contrôle ATS d'un CV.
///
/// **Ce que c'est.** Une simulation de ce qu'un ATS fait subir à un CV, à la
/// manière de Jobscan ou Resume Worded. Les vrais ATS — Taleo, Workday,
/// Greenhouse — n'exposent aucune API de notation : on ne peut pas leur
/// soumettre un document et récupérer une note. Ce qu'on peut faire, et qui
/// constitue tout le produit de ces outils, c'est vérifier les points sur
/// lesquels un CV se fait rejeter.
///
/// **Ce que ce n'est pas.** Un score inventé. Chaque ligne est calculée à
/// partir du document ; quand une vérification demande une information dont on
/// ne dispose pas — l'offre visée, pour les mots-clés — elle est marquée
/// indisponible plutôt que devinée. La maquette affiche « 14 / 15 » mots-clés
/// couverts ; ce chiffre exige une offre, et l'écran le réclame au lieu de
/// l'inventer.
class AtsReport {
  const AtsReport(this.checks);

  final List<AtsCheck> checks;

  /// Analyse un CV construit dans l'application.
  ///
  /// Le cas est favorable : le document est généré, donc sa structure est
  /// connue. Analyser un CV **importé** (PDF ou DOCX) est un autre problème —
  /// il faut d'abord en extraire le texte, et c'est justement là que la
  /// plupart des CV échouent.
  factory AtsReport.of(CvData data, {String? jobOffer}) {
    final info = data.personalInfo;
    final checks = <AtsCheck>[];

    // ── Coordonnées ─────────────────────────────────────────────────
    final hasEmail = info.email.trim().isNotEmpty;
    final hasPhone = info.phone.trim().isNotEmpty;
    checks.add(
      AtsCheck(
        label: 'Coordonnées détectables',
        status: hasEmail ? AtsStatus.ok : AtsStatus.warning,
        detail: hasEmail && hasPhone
            ? 'E-MAIL + TÉL.'
            : hasEmail
                ? 'E-MAIL'
                : 'MANQUANT',
        hint: hasEmail
            ? null
            : "Sans adresse e-mail, la candidature n'est pas rattachable.",
        weight: 2,
      ),
    );

    // ── Structure ───────────────────────────────────────────────────
    //
    // Un ATS échoue surtout sur la mise en page : colonnes, tableaux, texte
    // dans une image, en-têtes et pieds de page. Le PDF produit ici est en
    // une colonne, avec du texte réel — d'où la certitude.
    checks.add(
      const AtsCheck(
        label: 'Structure lisible par les robots',
        status: AtsStatus.ok,
        detail: 'OK',
        hint: 'Une seule colonne, texte réel, aucun tableau ni image.',
        weight: 2,
      ),
    );

    // ── Sections nommées ────────────────────────────────────────────
    final sections = <String>[
      if (data.experiences.isNotEmpty) 'Expérience',
      if (data.educations.isNotEmpty) 'Formation',
      if (data.skills.isNotEmpty) 'Compétences',
    ];
    checks.add(
      AtsCheck(
        label: 'Sections aux intitulés standards',
        status: sections.length >= 2 ? AtsStatus.ok : AtsStatus.warning,
        detail: '${sections.length} / 3',
        hint: sections.length >= 2
            ? null
            : 'Les ATS cherchent Expérience, Formation et Compétences.',
        weight: 2,
      ),
    );

    // ── Dates exploitables ──────────────────────────────────────────
    final dated = data.experiences.where((e) => e.period.isNotEmpty).length;
    final total = data.experiences.length;
    checks.add(
      AtsCheck(
        label: 'Dates renseignées',
        status: total == 0
            ? AtsStatus.warning
            : (dated == total ? AtsStatus.ok : AtsStatus.warning),
        detail: total == 0 ? 'AUCUN POSTE' : '$dated / $total',
        hint: dated == total && total > 0
            ? null
            : "Une expérience sans dates est souvent ignorée du calcul d'ancienneté.",
      ),
    );

    // ── Résultats chiffrés ──────────────────────────────────────────
    //
    // Le seul critère ici qui touche au fond plutôt qu'à la forme, et celui
    // que l'onboarding promet : « lignes précises, quantifiées ».
    final quantified = data.experiences
        .where((e) => RegExp(r'\d').hasMatch(e.description))
        .length;
    checks.add(
      AtsCheck(
        label: 'Résultats chiffrés',
        status: quantified > 0 ? AtsStatus.ok : AtsStatus.warning,
        detail: total == 0 ? '—' : '$quantified / $total',
        hint: quantified > 0
            ? null
            : 'Un chiffre vaut mieux qu’un adjectif : « +32 % » plutôt que '
                '« forte croissance ».',
      ),
    );

    // ── Mots-clés de l'offre ────────────────────────────────────────
    checks.add(_keywordCheck(data, jobOffer));

    return AtsReport(checks);
  }

  /// Correspondance avec l'offre visée — le cœur de valeur d'un contrôle ATS.
  ///
  /// Sans offre, la vérification est **indisponible** et non « échouée » :
  /// afficher un score de mots-clés sans savoir lesquels sont attendus n'aurait
  /// aucun sens.
  static AtsCheck _keywordCheck(CvData data, String? jobOffer) {
    final offer = jobOffer?.trim() ?? '';
    if (offer.isEmpty) {
      return const AtsCheck(
        label: 'Mots-clés du poste couverts',
        status: AtsStatus.unavailable,
        detail: 'À DÉFINIR',
        hint: "Collez l'offre visée pour mesurer la correspondance.",
        weight: 3,
      );
    }

    final keywords = _keywordsOf(offer);
    if (keywords.isEmpty) {
      return const AtsCheck(
        label: 'Mots-clés du poste couverts',
        status: AtsStatus.unavailable,
        detail: 'À DÉFINIR',
        weight: 3,
      );
    }

    final haystack = _documentText(data).toLowerCase();
    final covered = keywords.where(haystack.contains).length;
    final ratio = covered / keywords.length;

    return AtsCheck(
      label: 'Mots-clés du poste couverts',
      status: ratio >= 0.6 ? AtsStatus.ok : AtsStatus.warning,
      detail: '$covered / ${keywords.length}',
      hint: ratio >= 0.6
          ? null
          : 'Reprenez les termes de l’offre : les filtres comparent des '
              'chaînes, pas des synonymes.',
      weight: 3,
    );
  }

  /// Mots significatifs d'une offre : on retire la ponctuation, les mots
  /// courts et les mots vides du français, puis on déduplique.
  static List<String> _keywordsOf(String offer) {
    const stopWords = {
      'avec',
      'dans',
      'pour',
      'vous',
      'nous',
      'votre',
      'notre',
      'plus',
      'cette',
      'sont',
      'être',
      'avoir',
      'chez',
      'sur',
      'des',
      'les',
      'une',
      'aux',
      'par',
      'que',
      'qui',
      'est',
      'ses',
      'nos',
      'vos',
      'leur',
      'ainsi',
      'poste',
      'profil',
      'mission',
      'missions',
      'entreprise',
      'équipe',
      'recherche',
      'recherchons',
      'candidat',
      'candidate',
      'expérience',
      'ans',
      'sein',
      'afin',
      'tout',
      'tous',
      'toute',
      'entre',
      'aura',
    };

    final words = offer
        .toLowerCase()
        .split(RegExp(r"[^a-zà-ÿ0-9+#.]+"))
        .where((w) => w.length >= 4 && !stopWords.contains(w))
        .toSet()
        .toList();

    // Au-delà d'une trentaine de termes, le ratio perd son sens : une offre
    // longue diluerait la mesure.
    return words.take(30).toList();
  }

  static String _documentText(CvData d) {
    final info = d.personalInfo;
    return [
      info.fullName,
      info.jobTitle,
      info.summary,
      for (final e in d.experiences)
        '${e.position} ${e.company} ${e.description}',
      for (final e in d.educations) '${e.degree} ${e.schoolLine}',
      for (final s in d.skills) s.name,
      for (final l in d.languages) l.name,
    ].join(' ');
  }

  /// Note sur 100, pondérée. Les vérifications indisponibles sont **exclues**
  /// du calcul plutôt que comptées comme un échec : ne pas avoir renseigné
  /// d'offre n'est pas un défaut du CV.
  int get score {
    var earned = 0;
    var possible = 0;
    for (final c in checks) {
      if (c.status == AtsStatus.unavailable) continue;
      possible += c.weight;
      if (c.status == AtsStatus.ok) earned += c.weight;
    }
    if (possible == 0) return 0;
    return (earned / possible * 100).round();
  }

  int get okCount => checks.where((c) => c.status == AtsStatus.ok).length;

  bool get hasWarnings => checks.any((c) => c.status == AtsStatus.warning);
}
