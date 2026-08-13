import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cv_document.dart';

/// Persistance de la bibliothèque dans `SharedPreferences`.
///
/// Le projet Kotlin ne persistait rien : `CvViewModel` vivait dans la mémoire
/// de l'Activity et `sampleCvs` était une constante. Fermer l'application
/// perdait tout.
///
/// `SharedPreferences` convient au volume en jeu (quelques CV en JSON). Si la
/// bibliothèque grossit ou qu'un historique devient nécessaire, c'est ici
/// qu'il faudra basculer vers une vraie base — l'interface ne changera pas.
class CvStorage {
  CvStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _key = 'cv_documents';

  /// Sauvegarde du contenu illisible, conservé pour ne rien détruire en
  /// silence si la désérialisation échoue.
  static const String _corruptKey = 'cv_documents_corrupt';

  /// Renvoie `null` si rien n'a jamais été enregistré — ce qui déclenche
  /// l'exemple de démarrage. Une liste vide, elle, signifie que l'utilisateur
  /// a supprimé tous ses CV : on ne fait pas réapparaître l'exemple.
  List<CvDocument>? load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in decoded)
          CvDocument.fromJson(item as Map<String, dynamic>),
      ];
    } catch (e) {
      // Contenu corrompu : on le met de côté plutôt que de l'écraser, et on
      // repart d'une bibliothèque vide.
      debugPrint('CvStorage : contenu illisible, mis de côté ($e)');
      _prefs.setString(_corruptKey, raw);
      _prefs.remove(_key);
      return <CvDocument>[];
    }
  }

  Future<void> save(List<CvDocument> documents) {
    final raw = jsonEncode([for (final d in documents) d.toJson()]);
    return _prefs.setString(_key, raw);
  }
}

/// Relie une source de notifications à [CvStorage], en espaçant les écritures.
///
/// La bibliothèque notifie à chaque frappe ; écrire sur disque aussi souvent
/// serait inutile et coûteux. On regroupe les modifications sur une fenêtre
/// courte, et on écrit une fois la saisie retombée.
class DebouncedSaver {
  DebouncedSaver({
    required this.storage,
    required this.documents,
    this.delay = const Duration(milliseconds: 600),
  });

  final CvStorage storage;
  final List<CvDocument> Function() documents;
  final Duration delay;

  Timer? _timer;

  void schedule() {
    _timer?.cancel();
    _timer = Timer(delay, flush);
  }

  /// Écrit immédiatement — à appeler quand l'application passe en arrière-plan,
  /// pour ne pas perdre une saisie en cours.
  Future<void> flush() {
    _timer?.cancel();
    return storage.save(documents());
  }

  void dispose() => _timer?.cancel();
}
