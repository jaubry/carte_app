import 'package:flutter/material.dart';

class Categorie {
  const Categorie({
    required this.id,
    required this.libelle,
    required this.couleur,
  });

  final String id;
  final String libelle;
  final Color couleur;

  factory Categorie.fromJson(Map<String, dynamic> json) {
    final hex = (json['couleur'] as String? ?? '#607D8B')
        .replaceFirst('#', '');
    return Categorie(
      id: json['id'] as String,
      libelle: json['libelle'] as String,
      couleur: Color(int.parse('FF$hex', radix: 16)),
    );
  }
}

class Point {
  const Point({
    required this.id,
    required this.nom,
    required this.categorieId,
    required this.adresse,
    required this.latitude,
    required this.longitude,
    this.telephone,
    this.note,
    this.description,
    this.site,
  });

  final String id;
  final String nom;
  final String categorieId;
  final String adresse;
  final double latitude;
  final double longitude;
  final String? telephone;
  final double? note;
  final String? description;
  final String? site;

  /// Renvoie null si les coordonnées sont absentes ou invalides,
  /// pour que le point soit ignoré sans bloquer l'application.
  static Point? tryFromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble();
    final lng = (json['longitude'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;

    return Point(
      id: json['id'].toString(),
      nom: json['nom'] as String? ?? 'Sans nom',
      categorieId: json['categorie'] as String? ?? '',
      adresse: json['adresse'] as String? ?? '',
      latitude: lat,
      longitude: lng,
      telephone: json['telephone'] as String?,
      note: (json['note'] as num?)?.toDouble(),
      description: json['description'] as String?,
      site: json['site'] as String?,
    );
  }
}

class Referentiel {
  const Referentiel({
    required this.version,
    required this.categories,
    required this.points,
  });

  final String version;
  final List<Categorie> categories;
  final List<Point> points;

  Categorie? categoriePour(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  factory Referentiel.fromJson(Map<String, dynamic> json) {
    final categories = (json['categories'] as List<dynamic>? ?? [])
        .map((c) => Categorie.fromJson(c as Map<String, dynamic>))
        .toList();

    final points = (json['points'] as List<dynamic>? ?? [])
        .map((p) => Point.tryFromJson(p as Map<String, dynamic>))
        .whereType<Point>()
        .toList();

    return Referentiel(
      version: json['version']?.toString() ?? '',
      categories: categories,
      points: points,
    );
  }
}
