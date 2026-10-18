import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/referentiel.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.point, this.categorie});

  final Point point;
  final Categorie? categorie;

  Future<void> _ouvrir(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final p = point;

    return Scaffold(
      appBar: AppBar(title: Text(p.nom)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(p.nom, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          if (categorie != null)
            Chip(
              avatar: CircleAvatar(backgroundColor: categorie!.couleur),
              label: Text(categorie!.libelle),
            ),
          const SizedBox(height: 16),
          _ligne(Icons.place, p.adresse),
          if (p.telephone != null) _ligne(Icons.phone, p.telephone!),
          if (p.note != null) _ligne(Icons.star, '${p.note} / 5'),
          if (p.description != null && p.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(p.description!),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.directions),
            label: const Text('Itinéraire'),
            onPressed: () => _ouvrir(
              Uri.parse('geo:${p.latitude},${p.longitude}?q=${p.latitude},${p.longitude}(${Uri.encodeComponent(p.nom)})'),
            ),
          ),
          if (p.telephone != null) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.phone),
              label: const Text('Appeler'),
              onPressed: () => _ouvrir(
                Uri(scheme: 'tel', path: p.telephone!.replaceAll(' ', '')),
              ),
            ),
          ],
          if (p.site != null && p.site!.isNotEmpty) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.language),
              label: const Text('Site web'),
              onPressed: () => _ouvrir(Uri.parse(p.site!)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _ligne(IconData icone, String texte) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(texte)),
        ],
      ),
    );
  }
}
