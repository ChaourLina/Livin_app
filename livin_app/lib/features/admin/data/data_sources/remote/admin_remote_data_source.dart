import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/features/auth/data/models/auth_model.dart';
import 'package:livin_app/features/listings/data/models/listing_model.dart';

class AdminRemoteDataSource {
  // Motif écrit sur les annonces masquées automatiquement quand un compte est bloqué.
  static const String suspendedNote = 'Compte suspendu';

  final FirebaseFirestore _firestore;

  AdminRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<ListingModel>> getAllListings() async {
    try {
      final snapshot = await _firestore.collection('listings').get();
      return snapshot.docs
          .map((doc) => ListingModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<List<AuthModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs
          .map((doc) => AuthModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<void> setListingHidden({
    required String listingId,
    required bool hidden,
    required String note,
  }) async {
    try {
      await _firestore.collection('listings').doc(listingId).update({
        'hiddenByAdmin': hidden,
        'adminNote': hidden ? note : '',
      });
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<void> deleteListing(String listingId) async {
    try {
      await _firestore.collection('listings').doc(listingId).delete();
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<void> setUserBlocked({
    required String uid,
    required bool blocked,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isBlocked': blocked,
      });
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  // Masque (ou rétablit) les annonces d'un propriétaire en une seule opération.
  // Au rétablissement, seules les annonces masquées par le blocage du compte
  // sont remises en ligne : celles masquées à la main par un admin restent masquées.
  // (Une opération groupée Firestore accepte au plus 500 écritures.)
  Future<void> setOwnerListingsSuspended({
    required String ownerId,
    required bool suspended,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('ownerId', isEqualTo: ownerId)
          .get();
      final batch = _firestore.batch();
      var changes = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final hidden = data['hiddenByAdmin'] == true;
        final note = (data['adminNote'] ?? '') as String;
        if (suspended && !hidden) {
          batch.update(doc.reference, {
            'hiddenByAdmin': true,
            'adminNote': suspendedNote,
          });
          changes++;
        } else if (!suspended && hidden && note == suspendedNote) {
          batch.update(doc.reference, {
            'hiddenByAdmin': false,
            'adminNote': '',
          });
          changes++;
        }
      }
      if (changes > 0) await batch.commit();
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }
}