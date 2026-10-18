import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthLoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginSubmitted({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const AuthRegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, password];
}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthVerificationEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthVerificationEmailRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthLoggedOut extends AuthEvent {
  const AuthLoggedOut();
}

class AuthProfileUpdated extends AuthEvent {
  final String name;
  final String phone;
  final String? newPhotoPath;

  const AuthProfileUpdated({
    required this.name,
    required this.phone,
    this.newPhotoPath,
  });

  @override
  List<Object?> get props => [name, phone, newPhotoPath];
}