import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/failure.dart';
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

  Future<Either<Failure, List<Listing>>> getListings() {
    return guard(() async {
      final models = await remoteDataSource.getListings();
      final listings = models.map((model) => model.toEntity()).toList();
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    });
  }

  List<Listing> filterListings(List<Listing> listings, ListingFilter filter) {
    return listings.where((listing) => _matches(listing, filter)).toList();
  }

  Future<Either<Failure, List<Listing>>> getMyListings(String ownerId) {
    return guard(() async {
      final models = await remoteDataSource.getListingsByOwner(ownerId);
      final listings = models.map((model) => model.toEntity()).toList();
      listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listings;
    });
  }

  Future<Either<Failure, List<String>>> uploadImages(List<String> filePaths) {
    return guard(() async {
      final urls = <String>[];
      for (final path in filePaths) {
        urls.add(await imagesDataSource.uploadImage(path));
      }
      return urls;
    });
  }

  Future<Either<Failure, void>> createListing(Listing listing) {
    return guard<void>(() async {
      await remoteDataSource.createListing(ListingModel.fromEntity(listing));
    });
  }

  Future<Either<Failure, void>> updateListing(Listing listing) {
    return guard<void>(() async {
      await remoteDataSource.updateListing(ListingModel.fromEntity(listing));
    });
  }

  Future<Either<Failure, void>> deleteListing(String id) {
    return guard<void>(() async {
      await remoteDataSource.deleteListing(id);
    });
  }

  String _normalize(String text) {
    const accents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
    const plain = 'aaaaaaceeeeiiiinooooouuuuyy';
    var result = text.toLowerCase().trim();
    for (var i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], plain[i]);
    }
    return result;
  }

  bool _matches(Listing listing, ListingFilter filter) {
    if (!listing.isAvailable) return false;

    final query = _normalize(filter.query ?? '');
    if (query.isNotEmpty) {
      final text = _normalize(
        '${listing.title} ${listing.city} ${listing.type} '
        '${listing.description} ${listing.transactionType}',
      );
      final words = query.split(RegExp(r'\s+'));
      if (!words.every(text.contains)) return false;
    }
    if (filter.transactionType != null &&
        listing.transactionType != filter.transactionType) {
      return false;
    }
    if (filter.city != null &&
        _normalize(listing.city) != _normalize(filter.city!)) {
      return false;
    }
    if (filter.type != null &&
        _normalize(listing.type) != _normalize(filter.type!)) {
      return false;
    }
    if (filter.minPrice != null && listing.price < filter.minPrice!) {
      return false;
    }
    if (filter.maxPrice != null && listing.price > filter.maxPrice!) {
      return false;
    }
    if (filter.minRooms != null && listing.rooms < filter.minRooms!) {
      return false;
    }
    if (filter.minSurface != null && listing.surface < filter.minSurface!) {
      return false;
    }
    if (filter.amenities.isNotEmpty) {
      final owned = listing.amenities.map(_normalize).toSet();
      final allPresent =
          filter.amenities.every((amenity) => owned.contains(_normalize(amenity)));
      if (!allPresent) return false;
    }
    return true;
  }
}