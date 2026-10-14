import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/features/listings/data/models/listing_model.dart';

class ListingsRemoteDataSource {
  final FirebaseFirestore _firestore;

  ListingsRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('listings');

  Future<List<ListingModel>> getListings({String? transactionType}) async {
    try {
      Query<Map<String, dynamic>> query = _collection;
      if (transactionType != null) {
        query = query.where('transactionType', isEqualTo: transactionType);
      }
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ListingModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<List<ListingModel>> getListingsByOwner(String ownerId) async {
    try {
      final snapshot =
          await _collection.where('ownerId', isEqualTo: ownerId).get();
      return snapshot.docs
          .map((doc) => ListingModel.fromJson(doc.data()))
          .toList();
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<ListingModel> createListing(ListingModel listing) async {
    try {
      final doc = _collection.doc();
      final data = listing.toJson()..['id'] = doc.id;
      await doc.set(data);
      return ListingModel.fromJson(data);
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<void> updateListing(ListingModel listing) async {
    try {
      await _collection.doc(listing.id).update(listing.toJson());
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _collection.doc(id).delete();
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }
}