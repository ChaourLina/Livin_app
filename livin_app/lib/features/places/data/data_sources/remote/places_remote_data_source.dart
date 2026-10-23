import 'package:dio/dio.dart';
import 'package:livin_app/core/error/exceptions.dart';
import 'package:livin_app/features/places/data/models/place_model.dart';

class PlacesRemoteDataSource {
  final Dio _dio;

  PlacesRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  // Service public de recherche d'adresses d'OpenStreetMap (Nominatim).
  // Politique d'utilisation : 1 requête par seconde au maximum, un User-Agent
  // qui identifie l'application, et pas de recherche à chaque lettre tapée.
  Future<List<PlaceModel>> search(String query) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'jsonv2',
          'limit': 6,
          'countrycodes': 'dz',
          'accept-language': 'fr, ar',
        },
        options: Options(
          headers: {'User-Agent': 'Livin/1.0 (projet etudiant Flutter)'},
        ),
      );
      final data = response.data as List<dynamic>;
      return data
          .map((item) => PlaceModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException();
      }
      if (e.response?.statusCode == 429) {
        throw const ServerException(
          'Trop de recherches. Réessayez dans un instant.',
        );
      }
      throw const ServerException('La recherche d\'adresse a échoué.');
    }
  }
}