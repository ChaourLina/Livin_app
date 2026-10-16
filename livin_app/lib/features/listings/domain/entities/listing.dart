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
  final String city;
  final String contact;
  final List<String> photos;
  final DateTime createdAt;
  final bool isAvailable;

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
    this.isAvailable = true,
  });

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
      city: city,
      contact: contact,
      photos: photos ?? this.photos,
      createdAt: createdAt,
      isAvailable: isAvailable ?? this.isAvailable,
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
        city,
        contact,
        photos,
        createdAt,
        isAvailable,
      ];
}