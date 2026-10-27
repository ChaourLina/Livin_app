import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String photoUrl;
  final String role;
  final bool isBlocked;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.name,
    this.phone = '',
    this.address = '',
    this.photoUrl = '',
    this.role = 'user',
    this.isBlocked = false,
  });

  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props =>
      [uid, email, name, phone, address, photoUrl, role, isBlocked];
}