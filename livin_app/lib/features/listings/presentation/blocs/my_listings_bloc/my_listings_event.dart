import 'package:equatable/equatable.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

abstract class MyListingsEvent extends Equatable {
  const MyListingsEvent();

  @override
  List<Object?> get props => [];
}

class MyListingsStarted extends MyListingsEvent {
  final String ownerId;

  const MyListingsStarted({required this.ownerId});

  @override
  List<Object?> get props => [ownerId];
}

class MyListingCreated extends MyListingsEvent {
  final Listing listing;

  const MyListingCreated({required this.listing});

  @override
  List<Object?> get props => [listing];
}

class MyListingUpdated extends MyListingsEvent {
  final Listing listing;

  const MyListingUpdated({required this.listing});

  @override
  List<Object?> get props => [listing];
}

class MyListingDeleted extends MyListingsEvent {
  final String listingId;

  const MyListingDeleted({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}