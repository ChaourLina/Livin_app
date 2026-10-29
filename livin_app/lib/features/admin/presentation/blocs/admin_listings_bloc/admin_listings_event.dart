import 'package:equatable/equatable.dart';

abstract class AdminListingsEvent extends Equatable {
  const AdminListingsEvent();

  @override
  List<Object?> get props => [];
}

class AdminListingsStarted extends AdminListingsEvent {
  const AdminListingsStarted();
}

class AdminListingHidden extends AdminListingsEvent {
  final String listingId;
  final String note;

  const AdminListingHidden({required this.listingId, this.note = ''});

  @override
  List<Object?> get props => [listingId, note];
}

class AdminListingRestored extends AdminListingsEvent {
  final String listingId;

  const AdminListingRestored({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}

class AdminListingDeleted extends AdminListingsEvent {
  final String listingId;

  const AdminListingDeleted({required this.listingId});

  @override
  List<Object?> get props => [listingId];
}