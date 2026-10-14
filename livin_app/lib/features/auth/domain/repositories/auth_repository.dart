import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/exceptions.dart';
import 'package:livin_app/features/auth/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:livin_app/features/auth/domain/entities/auth_user.dart';
import 'package:livin_app/features/listings/data/data_sources/remote/images_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ImagesRemoteDataSource imagesDataSource;

  AuthRepository({
    required this.remoteDataSource,
    required this.imagesDataSource,
  });

  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final model =
          await remoteDataSource.login(email: email, password: password);
      return model.toEntity();
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final model = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      return model.toEntity();
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<AuthUser?> getCurrentUser() async {
    try {
      final model = await remoteDataSource.getCurrentUser();
      return model?.toEntity();
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<AuthUser> updateProfile({
    required AuthUser user,
    required String name,
    required String phone,
    String? newPhotoPath,
  }) async {
    try {
      var photoUrl = user.photoUrl;
      if (newPhotoPath != null) {
        photoUrl = await imagesDataSource.uploadImage(newPhotoPath);
      }
      final model = await remoteDataSource.updateProfile(
        uid: user.uid,
        name: name,
        phone: phone,
        photoUrl: photoUrl,
      );
      return model.toEntity();
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}