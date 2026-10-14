import 'package:equatable/equatable.dart';

class ListingFilter extends Equatable {
  final String? query;
  final String? transactionType;
  final String? city;
  final String? type;
  final int? minPrice;
  final int? maxPrice;
  final int? minRooms;

  const ListingFilter({
    this.query,
    this.transactionType,
    this.city,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
  });

  @override
  List<Object?> get props =>
      [query, transactionType, city, type, minPrice, maxPrice, minRooms];
}