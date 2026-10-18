import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/auth/domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthVerificationEmailRequested>(_onVerificationEmailRequested);
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthProfileUpdated>(_onProfileUpdated);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final result = await repository.getCurrentUser();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (user) => emit(
        user == null ? const AuthUnauthenticated() : AuthSuccess(user: user),
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await repository.login(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) {
        if (failure is EmailNotVerifiedFailure) {
          emit(AuthEmailNotVerified(email: event.email));
        } else {
          emit(AuthFailure(message: failure.message));
        }
      },
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await repository.register(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(AuthVerificationSent(email: event.email)),
    );
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await repository.sendPasswordReset(event.email);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(AuthPasswordResetSent(email: event.email)),
    );
  }

  Future<void> _onVerificationEmailRequested(
    AuthVerificationEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await repository.resendVerificationEmail(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(AuthVerificationSent(email: event.email)),
    );
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();
    emit(const AuthUnauthenticated());
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthSuccess) return;
    emit(AuthProfileUpdating(user: current.user));
    final result = await repository.updateProfile(
      user: current.user,
      name: event.name,
      phone: event.phone,
      newPhotoPath: event.newPhotoPath,
    );
    result.fold(
      (failure) => emit(
        AuthProfileFailure(user: current.user, message: failure.message),
      ),
      (updated) => emit(AuthSuccess(user: updated)),
    );
  }
}