import 'package:equatable/equatable.dart';
import 'package:livin_app/features/auth/domain/entities/auth_user.dart';

class AdminUser extends Equatable {
  final AuthUser user;
  final int listingsCount;

  const AdminUser({required this.user, required this.listingsCount});

  @override
  List<Object?> get props => [user, listingsCount];
}