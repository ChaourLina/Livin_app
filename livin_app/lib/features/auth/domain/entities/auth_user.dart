import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String uid;
  final String email;
  final String name;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.name,
  });

  @override
  List<Object?> get props => [uid, email, name];
}