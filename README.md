# Carte — squelette Flutter (version de test)

Application Android et iOS : une carte OpenStreetMap, des marqueurs issus
d'un référentiel JSON, un filtre par catégorie et un écran de détail.

## Mise en route

Ces fichiers sont le code source. Il faut un projet Flutter autour.

```bash
flutter create --org fr.exemple --project-name carte_app carte_app
cd carte_app
```

Remplacez ensuite `pubspec.yaml` et le dossier `lib/` par ceux de ce dossier,
puis lancez :

```bash
flutter pub get
flutter run
```

## Permissions à ajouter

**Android** — `android/app/src/main/AndroidManifest.xml`, avant `<application>` :

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** — `ios/Runner/Info.plist`, dans le `<dict>` principal :

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Pour centrer la carte sur votre position.</string>
```

## Réglages

Tout se règle dans `lib/config.dart` :
- `referentielUrl` : adresse du fichier JSON publié.
- `villeLatitude`, `villeLongitude`, `zoomInitial` : centre de la carte au démarrage.

## Points à vérifier avant publication

- **Tuiles OpenStreetMap** : le serveur public `tile.openstreetmap.org` est réservé
  à un usage modéré. Pour une diffusion large, passez par un fournisseur de tuiles
  (MapTiler, Stadia Maps, etc.) ou hébergez les tuiles vous-même.
- **Attribution** : « © OpenStreetMap contributors » doit rester affichée, ce que fait déjà le code.
- **Données** : le référentiel doit provenir de sources que vous avez le droit de réutiliser
  (voir ma remarque sur les données Google).
- **Hors ligne** : le dernier référentiel téléchargé est gardé en cache ; sans cache et sans réseau, un message d'erreur s'affiche.

## Ce qui reste à faire

- Tests sur appareil réel (le code n'a pas pu être compilé dans l'environnement où il a été écrit).
- Icônes et nom de l'application.
- Regroupement des marqueurs si la ville compte beaucoup de points.
