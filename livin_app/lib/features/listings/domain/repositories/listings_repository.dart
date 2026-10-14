import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/exceptions.dart';
import 'package:livin_app/features/listings/data/data_sources/remote/images_remote_data_source.dart';
import 'package:livin_app/features/listings/data/data_sources/remote/listings_remote_data_source.dart';
import 'package:livin_app/features/listings/data/models/listing_model.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';

class ListingsRepository {
  final ListingsRemoteDataSource remoteDataSource;
  final ImagesRemoteDataSource imagesDataSource;

  ListingsRepository({
    required this.remoteDataSource,
    required this.imagesDataSource,
  });

  Future<List<Listing>> getListings({
    ListingFilter filter = const ListingFilter(),
  }) async {
    try {
      final models = await remoteDataSource.getListings(
        transactionType: filter.transactionType,
      );
      final listings = models
          .map((model) => model.toEntity())
          .where((listing) => _matches(listing, filter))
          .toList();
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<List<Listing>> getMyListings(String ownerId) async {
    try {
      final models = await remoteDataSource.getListingsByOwner(ownerId);
      final listings = models.map((model) => model.toEntity()).toList();
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<List<String>> uploadImages(List<String> filePaths) async {
    try {
      final urls = <String>[];
      for (final path in filePaths) {
        urls.add(await imagesDataSource.uploadImage(path));
      }
      return urls;
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<Listing> createListing(Listing listing) async {
    try {
      final model = await remoteDataSource
          .createListing(ListingModel.fromEntity(listing));
      return model.toEntity();
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<void> updateListing(Listing listing) async {
    try {
      await remoteDataSource.updateListing(ListingModel.fromEntity(listing));
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await remoteDataSource.deleteListing(id);
    } on AppException catch (e) {
      throw exceptionToFailure(e);
    }
  }

  bool _matches(Listing listing, ListingFilter filter) {
    final query = filter.query?.trim().toLowerCase();
    if (query != null && query.isNotEmpty) {
      final text =
          '${listing.title} ${listing.city} ${listing.type} ${listing.description}'
              .toLowerCase();
      if (!text.contains(query)) return false;
    }
    if (filter.city != null && listing.city != filter.city) return false;
    if (filter.type != null && listing.type != filter.type) return false;
    if (filter.minPrice != null && listing.price < filter.minPrice!) {
      return false;
    }
    if (filter.maxPrice != null && listing.price > filter.maxPrice!) {
      return false;
    }
    if (filter.minRooms != null && listing.rooms < filter.minRooms!) {
      return false;
    }
    return true;
  }
}