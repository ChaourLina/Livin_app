import 'package:equatable/equatable.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesSuccess extends FavoritesState {
  final List<String> favoriteIds;
  final List<Listing> listings;

  const FavoritesSuccess({required this.favoriteIds, required this.listings});

  @override
  List<Object?> get props => [favoriteIds, listings];
}

class FavoritesFailure extends FavoritesState {
  final String message;

  const FavoritesFailure({required this.message});

  @override
  List<Object?> get props => [message];
}