// lib/state/categories_provider.dart
import 'package:charmy_craft_studio/models/category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesProvider = StreamProvider<List<CategoryModel>>((ref) {
  final firestore = FirebaseFirestore.instance;

  // FIX: Order by the new 'index' field to ensure "All" is first.
  final stream = firestore.collection('categories').orderBy('index').snapshots();

  return stream.map((snapshot) {
    return snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  });
});