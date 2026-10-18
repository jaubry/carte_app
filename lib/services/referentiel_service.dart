import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';
import '../models/referentiel.dart';

/// Charge le référentiel à chaque démarrage.
///
/// 1. Télécharge le JSON depuis [referentielUrl].
/// 2. En cas de succès, enregistre la version brute en cache.
/// 3. En cas d'échec (hors ligne, serveur indisponible), utilise le cache.
/// 4. S'il n'y a ni réseau ni cache, lève une [ReferentielIndisponible].
class ReferentielService {
  static const _cleCache = 'referentiel_cache';

  Future<Referentiel> charger() async {
    try {
      final reponse = await http
          .get(Uri.parse(referentielUrl))
          .timeout(delaiReseau);

      if (reponse.statusCode == 200) {
        final texte = utf8.decode(reponse.bodyBytes);
        final referentiel = Referentiel.fromJson(
          jsonDecode(texte) as Map<String, dynamic>,
        );
        await _sauvegarderCache(texte);
        return referentiel;
      }
    } catch (_) {
      // Ignoré volontairement : on bascule sur le cache ci-dessous.
    }

    final cache = await _lireCache();
    if (cache != null) {
      return Referentiel.fromJson(jsonDecode(cache) as Map<String, dynamic>);
    }

    throw const ReferentielIndisponible();
  }

  Future<void> _sauvegarderCache(String texte) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cleCache, texte);
  }

  Future<String?> _lireCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cleCache);
  }
}

class ReferentielIndisponible implements Exception {
  const ReferentielIndisponible();

  @override
  String toString() =>
      'Les données ne sont pas disponibles. Vérifiez votre connexion internet.';
}
