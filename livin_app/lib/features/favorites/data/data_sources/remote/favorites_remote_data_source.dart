import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:livin_app/core/error/error_handler.dart';

class FavoritesRemoteDataSource {
  final FirebaseFirestore _firestore;

  FavoritesRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String userId) =>
      _firestore.collection('favorites').doc(userId);

  Future<List<String>> getFavoriteIds(String userId) async {
    try {
      final doc = await _doc(userId).get();
      final data = doc.data();
      if (data == null) return [];
      return List<String>.from(data['listingIds'] ?? []);
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<void> addFavorite(String userId, String listingId) async {
    try {
      await _doc(userId).set({
        'listingIds': FieldValue.arrayUnion([listingId]),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }

  Future<void> removeFavorite(String userId, String listingId) async {
    try {
      await _doc(userId).set({
        'listingIds': FieldValue.arrayRemove([listingId]),
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }
}