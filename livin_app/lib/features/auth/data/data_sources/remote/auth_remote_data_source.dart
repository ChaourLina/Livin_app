import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:livin_app/core/error/error_handler.dart';
import 'package:livin_app/core/error/exceptions.dart';
import 'package:livin_app/features/auth/data/models/auth_model.dart';

class AuthRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<AuthModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists) {
        throw const NotFoundException('Profil utilisateur introuvable.');
      }
      return AuthModel.fromJson(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    } on FirebaseException {
      throw const ServerException();
    }
  }

  Future<AuthModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final model = AuthModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
      );
      await _firestore.collection('users').doc(model.uid).set(model.toJson());
      return model;
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    } on FirebaseException {
      throw const ServerException();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<AuthModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return AuthModel.fromJson(doc.data()!);
    } on FirebaseException {
      throw const ServerException();
    }
  }
    Future<AuthModel> updateProfile({
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
  }) async {
    try {
      final ref = _firestore.collection('users').doc(uid);
      await ref.update({'name': name, 'phone': phone, 'photoUrl': photoUrl});
      final doc = await ref.get();
      return AuthModel.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      throw handleFirestoreError(e);
    }
  }
}