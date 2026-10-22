import 'package:latlong2/latlong.dart';

class CityCenters {
  // Centre approximatif du pays (vue d'ensemble) et de la capitale (valeur par défaut).
  static final LatLng algeria = LatLng(28.0, 2.6);
  static final LatLng algiers = LatLng(36.7538, 3.0588);

  // Coordonnées approximatives du chef-lieu de chaque wilaya.
  // Elles servent seulement à centrer la carte : l'utilisateur place ensuite
  // précisément le logement en touchant la carte.
  static final Map<String, LatLng> _centers = {
    'Alger': LatLng(36.7538, 3.0588),
    'Jijel': LatLng(36.8200, 5.7667),
    'Oran': LatLng(35.6911, -0.6417),
    'Mostaganem': LatLng(35.9311, 0.0892),
    'Constantine': LatLng(36.3650, 6.6147),
    'Annaba': LatLng(36.9000, 7.7667),
    'Blida': LatLng(36.4700, 2.8300),
    'Boumerdès': LatLng(36.7664, 3.4772),
    'Sétif': LatLng(36.1911, 5.4137),
    'Tizi Ouzou': LatLng(36.7119, 4.0459),
    'Béjaïa': LatLng(36.7509, 5.0567),
    'Tlemcen': LatLng(34.8783, -1.3150),
    'Mascara': LatLng(35.3967, 0.1403),
    'Batna': LatLng(35.5559, 6.1741),
  };

  static LatLng of(String city) => _centers[city] ?? algiers;
}