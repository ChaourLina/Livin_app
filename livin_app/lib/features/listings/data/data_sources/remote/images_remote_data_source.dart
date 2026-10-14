import 'package:dio/dio.dart';
import 'package:livin_app/core/error/exceptions.dart';
import 'package:livin_app/core/utils/cloudinary_config.dart';

class ImagesRemoteDataSource {
  final Dio _dio;

  ImagesRemoteDataSource({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> uploadImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'upload_preset': CloudinaryConfig.uploadPreset,
      });
      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
        data: formData,
      );
      return response.data['secure_url'] as String;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      throw const ServerException('Échec de l\'envoi de la photo.');
    }
  }
}