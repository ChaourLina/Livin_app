import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String photoUrl;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.name,
    this.phone = '',
    this.address = '',
    this.photoUrl = '',
  });

  @override
  List<Object?> get props => [uid, email, name, phone, address, photoUrl];
}