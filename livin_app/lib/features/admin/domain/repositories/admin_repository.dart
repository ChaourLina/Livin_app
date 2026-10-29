import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/admin/data/data_sources/remote/admin_remote_data_source.dart';
import 'package:livin_app/features/admin/domain/entities/admin_listing.dart';
class AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepository({required this.remoteDataSource});

  // Toutes les annonces (même masquées), avec le nom et l'email du propriétaire.
  Future<Either<Failure, List<AdminListing>>> getListings() {
    return guard(() async {
      final listingModels = await remoteDataSource.getAllListings();
      final userModels = await remoteDataSource.getAllUsers();
      final owners = {for (final user in userModels) user.uid: user};

      final items = listingModels.map((model) {
        final owner = owners[model.ownerId];
        return AdminListing(
          listing: model.toEntity(),
          ownerName: owner?.name ?? 'Utilisateur inconnu',
          ownerEmail: owner?.email ?? '',
        );
      }).toList();

      items.sort((a, b) => b.listing.createdAt.compareTo(a.listing.createdAt));
      return items;
    });
  }

  Future<Either<Failure, void>> hideListing({
    required String listingId,
    required String note,
  }) {
    return guard<void>(
      () => remoteDataSource.setListingHidden(
        listingId: listingId,
        hidden: true,
        note: note,
      ),
    );
  }

  Future<Either<Failure, void>> restoreListing(String listingId) {
    return guard<void>(
      () => remoteDataSource.setListingHidden(
        listingId: listingId,
        hidden: false,
        note: '',
      ),
    );
  }

  Future<Either<Failure, void>> deleteListing(String listingId) {
    return guard<void>(() => remoteDataSource.deleteListing(listingId));
  }
}