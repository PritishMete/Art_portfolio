// lib/models/category.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? 'Unnamed',
      // Provide a default placeholder or handle empty URLs gracefully
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}