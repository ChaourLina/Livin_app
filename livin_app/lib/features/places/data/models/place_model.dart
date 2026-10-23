import 'package:livin_app/features/places/domain/entities/place.dart';

class PlaceModel {
  final String name;
  final double latitude;
  final double longitude;

  PlaceModel({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Nominatim renvoie la latitude et la longitude sous forme de texte.
  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      name: (json['display_name'] ?? '') as String,
      latitude: double.parse(json['lat'].toString()),
      longitude: double.parse(json['lon'].toString()),
    );
  }

  Place toEntity() {
    return Place(name: name, latitude: latitude, longitude: longitude);
  }
}