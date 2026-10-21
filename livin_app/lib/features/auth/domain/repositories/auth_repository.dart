import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/failure.dart';
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

  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  }) {
    return guard(() async {
      final model =
          await remoteDataSource.login(email: email, password: password);
      return model.toEntity();
    });
  }

  Future<Either<Failure, void>> register({
    required String name,
    required String email,
    required String password,
    required String address,
  }) {
    return guard<void>(
      () => remoteDataSource.register(
        name: name,
        email: email,
        password: password,
        address: address,
      ),
    );
  }

  Future<Either<Failure, void>> resendVerificationEmail({
    required String email,
    required String password,
  }) {
    return guard<void>(
      () => remoteDataSource.resendVerificationEmail(
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, void>> sendPasswordReset(String email) {
    return guard<void>(() => remoteDataSource.sendPasswordReset(email));
  }

  Future<Either<Failure, AuthUser?>> getCurrentUser() {
    return guard<AuthUser?>(() async {
      final model = await remoteDataSource.getCurrentUser();
      return model?.toEntity();
    });
  }

  Future<Either<Failure, AuthUser>> updateProfile({
    required AuthUser user,
    required String name,
    required String phone,
    required String address,
    String? newPhotoPath,
  }) {
    return guard(() async {
      var photoUrl = user.photoUrl;
      if (newPhotoPath != null) {
        photoUrl = await imagesDataSource.uploadImage(newPhotoPath);
      }
      final model = await remoteDataSource.updateProfile(
        uid: user.uid,
        name: name,
        phone: phone,
        address: address,
        photoUrl: photoUrl,
      );
      return model.toEntity();
    });
  }

  Future<Either<Failure, void>> logout() {
    return guard<void>(() async {
      await remoteDataSource.logout();
    });
  }
}