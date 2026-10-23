import 'package:equatable/equatable.dart';

abstract class PlaceSearchEvent extends Equatable {
  const PlaceSearchEvent();

  @override
  List<Object?> get props => [];
}

class PlaceSearchSubmitted extends PlaceSearchEvent {
  final String query;

  const PlaceSearchSubmitted({required this.query});

  @override
  List<Object?> get props => [query];
}

class PlaceSearchCleared extends PlaceSearchEvent {
  const PlaceSearchCleared();
}