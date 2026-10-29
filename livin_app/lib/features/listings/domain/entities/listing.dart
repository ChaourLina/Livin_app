import 'package:equatable/equatable.dart';

class Listing extends Equatable {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String type;
  final String transactionType;
  final int price;
  final int rooms;
  final int surface;
  final String city;
  final String contact;
  final List<String> amenities;
  final List<String> photos;
  final DateTime createdAt;
  final bool isAvailable;
  final double? latitude;
  final double? longitude;
  final bool hiddenByAdmin;
  final String adminNote;

  const Listing({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.type,
    required this.transactionType,
    required this.price,
    required this.rooms,
    required this.city,
    required this.contact,
    required this.photos,
    required this.createdAt,
    this.surface = 0,
    this.amenities = const [],
    this.isAvailable = true,
    this.latitude,
    this.longitude,
    this.hiddenByAdmin = false,
    this.adminNote = '',
  });

  bool get hasLocation => latitude != null && longitude != null;

  Listing copyWith({List<String>? photos, bool? isAvailable}) {
    return Listing(
      id: id,
      ownerId: ownerId,
      title: title,
      description: description,
      type: type,
      transactionType: transactionType,
      price: price,
      rooms: rooms,
      surface: surface,
      city: city,
      contact: contact,
      amenities: amenities,
      photos: photos ?? this.photos,
      createdAt: createdAt,
      isAvailable: isAvailable ?? this.isAvailable,
      latitude: latitude,
      longitude: longitude,
      hiddenByAdmin: hiddenByAdmin,
      adminNote: adminNote,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        title,
        description,
        type,
        transactionType,
        price,
        rooms,
        surface,
        city,
        contact,
        amenities,
        photos,
        createdAt,
        isAvailable,
        latitude,
        longitude,
        hiddenByAdmin,
        adminNote,
      ];
}