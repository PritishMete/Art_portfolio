// lib/state/favorites_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to get a stream of just the IDs of favorited artworks
final favoriteIdsProvider = StreamProvider<List<String>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getFavoritesStream(user.uid);
  }
  return Stream.value([]);
});

// NEW: Notifier to handle the logic of adding/removing favorites
class FavoritesNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  FavoritesNotifier(this._ref) : super(const AsyncData(null));

  Future<void> toggleFavorite(Artwork artwork) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      final firestoreService = _ref.read(firestoreServiceProvider);
      final isCurrentlyFavorite = await firestoreService.isFavorite(user.uid, artwork.id);

      if (isCurrentlyFavorite) {
        await firestoreService.removeFavorite(user.uid, artwork.id);
      } else {
        await firestoreService.addFavorite(user.uid, artwork.id);
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Provider for the new notifier
final favoritesNotifierProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<void>>((ref) {
  return FavoritesNotifier(ref);
});


// The main provider that the UI will watch.
// It watches the IDs from the first provider and fetches the full Artwork objects.
final favoritesProvider = StreamProvider<List<Artwork>>((ref) {
  final favoriteIds = ref.watch(favoriteIdsProvider).value ?? [];

  if (favoriteIds.isEmpty) {
    return Stream.value([]);
  }

  // Query the 'artworks' collection for documents where the ID is in our list of favorites
  final stream = FirebaseFirestore.instance
      .collection('artworks')
      .where(FieldPath.documentId, whereIn: favoriteIds)
      .snapshots();

  return stream.map((snapshot) {
    return snapshot.docs.map((doc) => Artwork.fromFirestore(doc)).toList();
  });
});