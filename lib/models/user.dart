// lib/models/user.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final String? displayName; // Optional: for future use
  final String? photoUrl;    // Optional: for future use

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      // Default to 'user' role if not specified
      role: data['role'] ?? 'user',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
    );
  }

  // Method to convert a UserModel instance to a map for writing to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}