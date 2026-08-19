/// Polices proposées pour le CV lui-même — onglet Modèles.
///
/// À distinguer de la typographie de l'application, qui est fixe : ici c'est
/// le **document** que l'utilisateur habille.
///
/// La gamme est volontairement courte et couvre les registres plutôt que de
/// multiplier les variantes : deux sans-serif, deux serif, une monospace.
/// Chaque famille est embarquée dans l'application — aucune n'est téléchargée
/// à l'exécution.
///
/// **Le choix n'influence pas le score ATS.** Les filtres lisent le texte du
/// PDF, pas son dessin ; tant que le document contient du vrai texte — ce qui
/// est le cas ici — la police est une question d'apparence. L'interface le dit
/// explicitement, pour ne pas laisser croire qu'une police « passerait mieux ».
enum CvFont {
  inter(
    'Inter',
    label: 'Inter',
    kind: 'Sans-serif',
    description: 'Neutre et très lisible. Le choix sûr, dessiné pour les '
        'écrans comme pour le papier.',
    asset: 'assets/fonts/Inter-Variable.ttf',
  ),
  plex(
    'IBMPlexSans',
    label: 'IBM Plex Sans',
    kind: 'Sans-serif',
    description: 'Un sans-serif avec du caractère, sans excès. Convient aux '
        'profils techniques et produit.',
    asset: 'assets/fonts/IBMPlexSans-Variable.ttf',
  ),
  sourceSerif(
    'SourceSerif4',
    label: 'Source Serif',
    kind: 'Serif',
    description: 'Serif de lecture, sobre et institutionnel. Pour les '
        'secteurs classiques : droit, finance, recherche.',
    asset: 'assets/fonts/SourceSerif4-Variable.ttf',
  ),
  lora(
    'Lora',
    label: 'Lora',
    kind: 'Serif',
    description: 'Serif chaleureux, aux formes plus douces. Adoucit un CV '
        'très dense.',
    asset: 'assets/fonts/Lora-Variable.ttf',
  ),
  mono(
    'JetBrainsMono',
    label: 'JetBrains Mono',
    kind: 'Monospace',
    description: 'Chasse fixe, parti pris affirmé. Lisible par les ATS, mais '
        'à réserver aux profils techniques.',
    asset: 'assets/fonts/JetBrainsMono-Variable.ttf',
  );

  const CvFont(
    this.family, {
    required this.label,
    required this.kind,
    required this.description,
    required this.asset,
  });

  /// Nom de la famille tel que déclaré dans `pubspec.yaml`.
  final String family;

  final String label;

  /// Registre affiché sous le nom — « Serif », « Sans-serif », « Monospace ».
  final String kind;

  final String description;

  /// Chemin du fichier, nécessaire au générateur PDF : le paquet `pdf` ne
  /// connaît pas les familles Flutter et veut les octets de la police.
  final String asset;

  static const CvFont fallback = CvFont.inter;

  /// Retrouve une police par son nom de famille, avec repli — un document
  /// enregistré avant l'ajout d'une famille, ou avec une famille retirée
  /// depuis, doit continuer à s'ouvrir.
  static CvFont fromFamily(String? family) {
    if (family == null) return fallback;
    for (final f in CvFont.values) {
      if (f.family == family) return f;
    }
    return fallback;
  }
}
