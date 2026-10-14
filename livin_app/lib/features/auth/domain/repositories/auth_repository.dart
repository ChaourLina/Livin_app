import 'package:livin_app/core/error/exceptions.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:livin_app/features/auth/domain/entities/auth_user.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository({required AuthRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final model =
          await _remoteDataSource.login(email: email, password: password);
      return model.toEntity();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      return model.toEntity();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final model = await _remoteDataSource.getCurrentUser();
      return model?.toEntity();
    } on AppException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<void> logout() async {
    await _remoteDataSource.logout();
  }

  Failure _toFailure(AppException e) {
    if (e is NetworkException) return NetworkFailure(e.message);
    if (e is UnauthorizedException) return UnauthorizedFailure(e.message);
    if (e is NotFoundException) return NotFoundFailure(e.message);
    if (e is ServerException) return ServerFailure(e.message);
    return UnknownFailure(e.message);
  }
}