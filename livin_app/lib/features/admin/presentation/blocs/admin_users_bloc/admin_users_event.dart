import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

class AdminUsersStarted extends AdminUsersEvent {
  const AdminUsersStarted();
}

class AdminUserBlocked extends AdminUsersEvent {
  final String uid;
  final bool hideListings;

  const AdminUserBlocked({required this.uid, required this.hideListings});

  @override
  List<Object?> get props => [uid, hideListings];
}

class AdminUserUnblocked extends AdminUsersEvent {
  final String uid;

  const AdminUserUnblocked({required this.uid});

  @override
  List<Object?> get props => [uid];
}