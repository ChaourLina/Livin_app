import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/features/auth/data/models/auth_model.dart';
import 'package:livin_app/features/listings/data/models/listing_model.dart';

class AdminRemoteDataSource {
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
}