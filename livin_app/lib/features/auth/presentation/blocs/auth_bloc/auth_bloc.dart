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
    on<AuthLoggedOut>(_onLoggedOut);
    on<AuthProfileUpdated>(_onProfileUpdated);
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    try {
      final user = await repository.getCurrentUser();
      if (user != null) {
        emit(AuthSuccess(user: user));
      } else {
        emit(const AuthInitial());
      }
    } on Failure {
      emit(const AuthInitial());
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await repository.login(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user: user));
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    }
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await repository.register(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(user: user));
    } on Failure catch (failure) {
      emit(AuthFailure(message: failure.message));
    }
  }

  Future<void> _onLoggedOut(
    AuthLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await repository.logout();
    emit(const AuthInitial());
  }

  Future<void> _onProfileUpdated(
    AuthProfileUpdated event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthSuccess) return;
    emit(AuthProfileUpdating(user: current.user));
    try {
      final updated = await repository.updateProfile(
        user: current.user,
        name: event.name,
        phone: event.phone,
        newPhotoPath: event.newPhotoPath,
      );
      emit(AuthSuccess(user: updated));
    } on Failure catch (failure) {
      emit(AuthProfileFailure(user: current.user, message: failure.message));
    }
  }
}