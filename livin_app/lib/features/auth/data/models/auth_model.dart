import 'package:livin_app/features/auth/domain/entities/auth_user.dart';

class AuthModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String address;
  final String photoUrl;

  AuthModel({
    required this.uid,
    required this.email,
    required this.name,
    this.phone = '',
    this.address = '',
    this.photoUrl = '',
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
    };
  }

  AuthUser toEntity() {
    return AuthUser(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      address: address,
      photoUrl: photoUrl,
    );
  }

  factory AuthModel.fromEntity(AuthUser user) {
    return AuthModel(
      uid: user.uid,
      email: user.email,
      name: user.name,
      phone: user.phone,
      address: user.address,
      photoUrl: user.photoUrl,
    );
  }
}