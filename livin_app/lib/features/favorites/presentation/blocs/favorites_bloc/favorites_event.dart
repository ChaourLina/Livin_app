import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class FavoritesStarted extends FavoritesEvent {
  final String userId;

  const FavoritesStarted({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class FavoriteToggled extends FavoritesEvent {
  final String listingId;

  const FavoriteToggled({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}