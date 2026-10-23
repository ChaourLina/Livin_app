import 'package:equatable/equatable.dart';
import 'package:livin_app/features/places/domain/entities/place.dart';

abstract class PlaceSearchState extends Equatable {
  const PlaceSearchState();

  @override
  List<Object?> get props => [];
}

class PlaceSearchInitial extends PlaceSearchState {
  const PlaceSearchInitial();
}

class PlaceSearchLoading extends PlaceSearchState {
  const PlaceSearchLoading();
}

class PlaceSearchSuccess extends PlaceSearchState {
  final List<Place> places;

  const PlaceSearchSuccess({required this.places});

  @override
  List<Object?> get props => [places];
}

class PlaceSearchFailure extends PlaceSearchState {
  final String message;

  const PlaceSearchFailure({required this.message});

  @override
  List<Object?> get props => [message];
}