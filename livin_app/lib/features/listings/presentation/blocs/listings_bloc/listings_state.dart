import 'package:equatable/equatable.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';

abstract class ListingsState extends Equatable {
  const ListingsState();

  @override
  List<Object?> get props => [];
}

class ListingsInitial extends ListingsState {
  const ListingsInitial();
}

class ListingsLoading extends ListingsState {
  const ListingsLoading();
}

class ListingsSuccess extends ListingsState {
  final List<Listing> listings;
  final ListingFilter filter;

  const ListingsSuccess({required this.listings, required this.filter});

  @override
  List<Object?> get props => [listings, filter];
}

class ListingsFailure extends ListingsState {
  final String message;

  const ListingsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}