import 'package:equatable/equatable.dart';

class ListingFilter extends Equatable {
  final String? query;
  final String? transactionType;
  final String? city;
  final String? type;
  final int? minPrice;
  final int? maxPrice;
  final int? minRooms;
  final int? minSurface;
  final List<String> amenities;

  const ListingFilter({
    this.query,
    this.transactionType,
    this.city,
    this.type,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
    this.minSurface,
    this.amenities = const [],
  });

  bool get hasAdvanced =>
      minPrice != null ||
      maxPrice != null ||
      minRooms != null ||
      minSurface != null ||
      amenities.isNotEmpty;

  @override
  List<Object?> get props => [
        query,
        transactionType,
        city,
        type,
        minPrice,
        maxPrice,
        minRooms,
        minSurface,
        amenities,
      ];
}