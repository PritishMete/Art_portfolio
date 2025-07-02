// lib/state/artwork_provider.dart
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The provider now uses .family to accept a category filter string.
// It will rebuild automatically when the filter string changes.
final artworksProvider =
StreamProvider.family<List<Artwork>, String>((ref, category) {
  Query query = FirebaseFirestore.instance
      .collection('artworks')
      .where('isArchived', isEqualTo: false);

  // If a specific category is chosen (not 'All'), add a filter.
  if (category != 'All') {
    query = query.where('category', isEqualTo: category);
  }

  return query.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList();
  });
});