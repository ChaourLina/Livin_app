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
  final List<String> photos;
  final DateTime createdAt;

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
    required this.photos,
    required this.createdAt,
  });

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
        photos,
        createdAt,
      ];
}