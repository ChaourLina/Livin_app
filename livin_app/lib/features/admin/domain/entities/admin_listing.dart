import 'package:equatable/equatable.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

class AdminListing extends Equatable {
  final Listing listing;
  final String ownerName;
  final String ownerEmail;

  const AdminListing({
    required this.listing,
    required this.ownerName,
    required this.ownerEmail,
  });

  @override
  List<Object?> get props => [listing, ownerName, ownerEmail];
}