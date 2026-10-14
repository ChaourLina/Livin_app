import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/exceptions.dart';
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

  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      return await favoritesDataSource.getFavoriteIds(userId);
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<List<Listing>> getFavoriteListings(List<String> ids) async {
    try {
      final models = await listingsDataSource.getListingsByIds(ids);
      return models.map((model) => model.toEntity()).toList();
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<void> toggleFavorite({
    required String userId,
    required String listingId,
    required bool isFavorite,
  }) async {
    try {
      if (isFavorite) {
        await favoritesDataSource.removeFavorite(userId, listingId);
      } else {
        await favoritesDataSource.addFavorite(userId, listingId);
      }
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }
}