import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../config.dart';
import '../models/referentiel.dart';
import '../services/referentiel_service.dart';
import 'detail_screen.dart';

class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});

  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  final _mapController = MapController();
  final _service = ReferentielService();

  Referentiel? _referentiel;
  String? _erreur;
  bool _chargement = true;

  /// Catégories cochées dans le filtre. Au départ, toutes sont affichées.
  final Set<String> _filtre = {};

  @override
  void initState() {
    super.initState();
    _chargerReferentiel();
  }

  Future<void> _chargerReferentiel() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });
    try {
      final referentiel = await _service.charger();
      if (!mounted) return;
      setState(() {
        _referentiel = referentiel;
        _filtre
          ..clear()
          ..addAll(referentiel.categories.map((c) => c.id));
        _chargement = false;
      });
    } on ReferentielIndisponible catch (e) {
      if (!mounted) return;
      setState(() {
        _erreur = e.toString();
        _chargement = false;
      });
    }
  }

  List<Point> get _pointsAffiches {
    final r = _referentiel;
    if (r == null) return const [];
    return r.points.where((p) => _filtre.contains(p.categorieId)).toList();
  }

  Future<void> _centrerSurMoi() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Accès à la position refusé.')),
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15,
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Position indisponible.')),
      );
    }
  }

  void _ouvrirFiltre() {
    final r = _referentiel;
    if (r == null) return;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catégories',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...r.categories.map((c) {
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: CircleAvatar(
                          radius: 8,
                          backgroundColor: c.couleur,
                        ),
                        title: Text(c.libelle),
                        value: _filtre.contains(c.id),
                        onChanged: (coche) {
                          setState(() {
                            coche == true
                                ? _filtre.add(c.id)
                                : _filtre.remove(c.id);
                          });
                          setSheetState(() {});
                        },
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _filtre
                                ..clear()
                                ..addAll(r.categories.map((c) => c.id));
                            });
                            setSheetState(() {});
                          },
                          child: const Text('Tout afficher'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _couleurDe(Point p) {
    return _referentiel?.categoriePour(p.categorieId)?.couleur ??
        Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final points = _pointsAffiches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer',
            onPressed: _referentiel == null ? null : _ouvrirFiltre,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(villeLatitude, villeLongitude),
              initialZoom: zoomInitial,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'fr.exemple.carte_app',
              ),
              MarkerLayer(
                markers: points.map((p) {
                  return Marker(
                    point: LatLng(p.latitude, p.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              point: p,
                              categorie:
                                  _referentiel?.categoriePour(p.categorieId),
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.location_on,
                        color: _couleurDe(p),
                        size: 40,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (_chargement) const Center(child: CircularProgressIndicator()),
          if (_erreur != null)
            Center(
              child: Card(
                margin: const EdgeInsets.all(24),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_erreur!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _chargerReferentiel,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Me localiser',
        onPressed: _centrerSurMoi,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
