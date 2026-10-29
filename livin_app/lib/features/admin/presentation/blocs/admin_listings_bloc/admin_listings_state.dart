import 'package:equatable/equatable.dart';
import 'package:livin_app/features/admin/domain/entities/admin_listing.dart';

abstract class AdminListingsState extends Equatable {
  const AdminListingsState();

  @override
  List<Object?> get props => [];
}

class AdminListingsInitial extends AdminListingsState {
  const AdminListingsInitial();
}

class AdminListingsLoading extends AdminListingsState {
  const AdminListingsLoading();
}

class AdminListingsSuccess extends AdminListingsState {
  final List<AdminListing> items;

  const AdminListingsSuccess({required this.items});

  @override
  List<Object?> get props => [items];
}

class AdminListingsFailure extends AdminListingsState {
  final String message;

  const AdminListingsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}