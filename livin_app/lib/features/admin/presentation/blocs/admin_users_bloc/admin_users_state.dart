import 'package:equatable/equatable.dart';
import 'package:livin_app/features/admin/domain/entities/admin_user.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {
  const AdminUsersInitial();
}

class AdminUsersLoading extends AdminUsersState {
  const AdminUsersLoading();
}

class AdminUsersSuccess extends AdminUsersState {
  final List<AdminUser> users;

  const AdminUsersSuccess({required this.users});

  @override
  List<Object?> get props => [users];
}

class AdminUsersFailure extends AdminUsersState {
  final String message;

  const AdminUsersFailure({required this.message});

  @override
  List<Object?> get props => [message];
}