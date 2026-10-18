import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

class ListingModel {
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

  ListingModel({
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
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'],
      ownerId: json['ownerId'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      transactionType: json['transactionType'],
      price: (json['price'] as num).toInt(),
      rooms: (json['rooms'] as num).toInt(),
      surface: (json['surface'] as num?)?.toInt() ?? 0,
      city: json['city'],
      contact: json['contact'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      photos: List<String>.from(json['photos'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'type': type,
      'transactionType': transactionType,
      'price': price,
      'rooms': rooms,
      'surface': surface,
      'city': city,
      'contact': contact,
      'amenities': amenities,
      'photos': photos,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAvailable': isAvailable,
    };
  }

  Listing toEntity() {
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
      photos: photos,
      createdAt: createdAt,
      isAvailable: isAvailable,
    );
  }

  factory ListingModel.fromEntity(Listing listing) {
    return ListingModel(
      id: listing.id,
      ownerId: listing.ownerId,
      title: listing.title,
      description: listing.description,
      type: listing.type,
      transactionType: listing.transactionType,
      price: listing.price,
      rooms: listing.rooms,
      surface: listing.surface,
      city: listing.city,
      contact: listing.contact,
      amenities: listing.amenities,
      photos: listing.photos,
      createdAt: listing.createdAt,
      isAvailable: listing.isAvailable,
    );
  }
}