// lib/state/creator_uploads_provider.dart

import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider fetches ALL artworks belonging to the current user (creator)
final creatorArtworksProvider = StreamProvider<List<Artwork>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    return Stream.value([]);
  }

  final collection = FirebaseFirestore.instance
      .collection('artworks')
      .where('artist', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true);

  return collection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList();
  });
});