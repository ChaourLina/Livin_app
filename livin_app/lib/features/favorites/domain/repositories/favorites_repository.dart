import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/favorites/data/data_sources/remote/favorites_remote_data_source.dart';
import 'package:livin_app/features/listings/data/data_sources/remote/listings_remote_data_source.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';

class FavoritesRepository {
  final FavoritesRemoteDataSource favoritesDataSource;
  final ListingsRemoteDataSource listingsDataSource;

  FavoritesRepository({
    required this.favoritesDataSource,
    required this.listingsDataSource,
  });

  Future<Either<Failure, List<String>>> getFavoriteIds(String userId) {
    return guard(() => favoritesDataSource.getFavoriteIds(userId));
  }

  Future<Either<Failure, List<Listing>>> getFavoriteListings(
    List<String> ids,
  ) {
    return guard(() async {
      final models = await listingsDataSource.getListingsByIds(ids);
          return models
          .map((model) => model.toEntity())
          .where((listing) => listing.isAvailable && !listing.hiddenByAdmin)
          .toList();
    });
  }

  Future<Either<Failure, void>> toggleFavorite({
    required String userId,
    required String listingId,
    required bool isFavorite,
  }) {
    return guard<void>(() async {
      if (isFavorite) {
        await favoritesDataSource.removeFavorite(userId, listingId);
      } else {
        await favoritesDataSource.addFavorite(userId, listingId);
      }
    });
  }
}