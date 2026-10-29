import 'package:livin_app/core/error/either.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/failure.dart';
import 'package:livin_app/features/admin/data/data_sources/remote/admin_remote_data_source.dart';
import 'package:livin_app/features/admin/domain/entities/admin_listing.dart';
import 'package:livin_app/features/admin/domain/entities/admin_user.dart';

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

  // Tous les utilisateurs, avec le nombre d'annonces de chacun.
  // Les administrateurs sont placés en premier, puis tri par nom.
  Future<Either<Failure, List<AdminUser>>> getUsers() {
    return guard(() async {
      final userModels = await remoteDataSource.getAllUsers();
      final listingModels = await remoteDataSource.getAllListings();

      final counts = <String, int>{};
      for (final listing in listingModels) {
        counts[listing.ownerId] = (counts[listing.ownerId] ?? 0) + 1;
      }

      final items = userModels
          .map(
            (model) => AdminUser(
              user: model.toEntity(),
              listingsCount: counts[model.uid] ?? 0,
            ),
          )
          .toList();

      items.sort((a, b) {
        if (a.user.isAdmin != b.user.isAdmin) return a.user.isAdmin ? -1 : 1;
        return a.user.name.toLowerCase().compareTo(b.user.name.toLowerCase());
      });
      return items;
    });
  }

  Future<Either<Failure, void>> blockUser({
    required String uid,
    required bool hideListings,
  }) {
    return guard<void>(() async {
      await remoteDataSource.setUserBlocked(uid: uid, blocked: true);
      if (hideListings) {
        await remoteDataSource.setOwnerListingsSuspended(
          ownerId: uid,
          suspended: true,
        );
      }
    });
  }

  Future<Either<Failure, void>> unblockUser(String uid) {
    return guard<void>(() async {
      await remoteDataSource.setUserBlocked(uid: uid, blocked: false);
      await remoteDataSource.setOwnerListingsSuspended(
        ownerId: uid,
        suspended: false,
      );
    });
  }
}