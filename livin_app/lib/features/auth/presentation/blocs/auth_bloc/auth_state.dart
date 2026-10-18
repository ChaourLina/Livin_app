import 'package:equatable/equatable.dart';
import 'package:livin_app/features/auth/domain/entities/auth_user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthVerificationSent extends AuthState {
  final String email;

  const AuthVerificationSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthEmailNotVerified extends AuthState {
  final String email;

  const AuthEmailNotVerified({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthSuccess extends AuthState {
  final AuthUser user;

  const AuthSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthProfileUpdating extends AuthSuccess {
  const AuthProfileUpdating({required super.user});
}

class AuthProfileFailure extends AuthSuccess {
  final String message;

  const AuthProfileFailure({required super.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object?> get props => [message];
}