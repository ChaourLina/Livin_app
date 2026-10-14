import 'package:equatable/equatable.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

abstract class MyListingsState extends Equatable {
  const MyListingsState();

  @override
  List<Object?> get props => [];
}

class MyListingsInitial extends MyListingsState {
  const MyListingsInitial();
}

class MyListingsLoading extends MyListingsState {
  const MyListingsLoading();
}

class MyListingsSuccess extends MyListingsState {
  final List<Listing> listings;

  const MyListingsSuccess({required this.listings});

  @override
  List<Object?> get props => [listings];
}

class MyListingsFailure extends MyListingsState {
  final String message;

  const MyListingsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}