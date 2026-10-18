/// Réglages de l'application. Seule cette valeur doit changer
/// quand le référentiel est publié sur son hébergement définitif.
const String referentielUrl = 'https://exemple.fr/referentiel.json';

/// Ville affichée au démarrage (Guichen).
const double villeLatitude = 47.9800;
const double villeLongitude = -1.7850;
const double zoomInitial = 13;

/// Délai maximal d'attente du téléchargement du référentiel.
const Duration delaiReseau = Duration(seconds: 10);
