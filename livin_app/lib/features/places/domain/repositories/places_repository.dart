import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/places/data/data_sources/remote/places_remote_data_source.dart';
import 'package:livin_app/features/places/domain/entities/place.dart';

class PlacesRepository {
  final PlacesRemoteDataSource remoteDataSource;

  PlacesRepository({required this.remoteDataSource});

  Future<Either<Failure, List<Place>>> searchPlaces(String query) {
    return guard(() async {
      final models = await remoteDataSource.search(query);
      return models.map((model) => model.toEntity()).toList();
    });
  }
}