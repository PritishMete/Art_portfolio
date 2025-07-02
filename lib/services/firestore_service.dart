// lib/services/firestore_service.dart

import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/models/creator_profile.dart';
import 'package:charmy_craft_studio/models/user.dart';
import 'package:charmy_craft_studio/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Ref _ref;

  FirestoreService(this._ref);

  // --- User Methods ---
  Future<UserModel?> getUser(String uid) async {
    final docSnap = await _db.collection('users').doc(uid).get();
    if (docSnap.exists) {
      return UserModel.fromFirestore(docSnap);
    }
    return null;
  }

  Future<void> setUser(User user, {String? name}) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();
    final role = doc.exists ? doc.data()!['role'] : 'user';
    await userRef.set(
      {
        'uid': user.uid,
        'email': user.email,
        'displayName': name ?? user.displayName,
        'photoUrl': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
        'role': role,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> updateUserDisplayName(String uid, String newName) async {
    try {
      await _db.collection('users').doc(uid).update({'displayName': newName});
      await updateCreatorProfileDetails({'displayName': newName});
    } catch (e) {
      throw Exception('Error updating display name in Firestore: $e');
    }
  }

  Future<void> updateUserPhotoUrl(String uid, String newPhotoUrl) async {
    try {
      await _db.collection('users').doc(uid).update({'photoUrl': newPhotoUrl});
    } catch (e) {
      throw Exception('Error updating photo URL in Firestore: $e');
    }
  }

  // --- Artwork Methods ---
  Future<void> addArtwork(Artwork artwork) async {
    try {
      await _db.collection('artworks').add(artwork.toMap());
    } catch (e) {
      throw Exception('Error adding artwork to Firestore: $e');
    }
  }

  Future<void> updateArtwork(Artwork artwork) async {
    try {
      await _db.collection('artworks').doc(artwork.id).update(artwork.toMap());
    } catch (e) {
      throw Exception('Error updating artwork: $e');
    }
  }

  Future<void> setArtworkArchivedStatus(
      String artworkId, bool isArchived) async {
    try {
      await _db
          .collection('artworks')
          .doc(artworkId)
          .update({'isArchived': isArchived});
    } catch (e) {
      throw Exception('Error updating archive status: $e');
    }
  }

  Future<void> deleteArtwork(Artwork artwork) async {
    try {
      final storageService = _ref.read(storageServiceProvider);

      if (artwork.imageUrls.isNotEmpty) {
        for (final url in artwork.imageUrls) {
          await storageService.deleteImageFromUrl(url);
        }
      }
      if (artwork.thumbnailUrl.isNotEmpty) {
        await storageService.deleteImageFromUrl(artwork.thumbnailUrl);
      }

      await _db.collection('artworks').doc(artwork.id).delete();
    } catch (e) {
      throw Exception('Error deleting artwork: $e');
    }
  }

  // --- Favorite Methods ---
  Stream<List<String>> getFavoritesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<bool> isFavorite(String userId, String artworkId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(artworkId)
        .get();
    return doc.exists;
  }

  Future<void> addFavorite(String userId, String artworkId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(artworkId)
        .set({'favoritedAt': FieldValue.serverTimestamp()});
  }

  Future<void> removeFavorite(String userId, String artworkId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(artworkId)
        .delete();
  }

  // --- Category Methods ---
  Future<void> addCategory(String categoryName) async {
    try {
      final querySnapshot = await _db
          .collection('categories')
          .orderBy('index', descending: true)
          .limit(1)
          .get();

      int newIndex = 1;
      if (querySnapshot.docs.isNotEmpty) {
        newIndex = (querySnapshot.docs.first.data()['index'] ?? 0) + 1;
      }

      await _db.collection('categories').add({
        'name': categoryName,
        'imageUrl': '',
        'index': newIndex,
      });
    } catch (e) {
      throw Exception('Error adding category: $e');
    }
  }

  Future<void> updateCategoryThumbnail(
      String categoryId, String newImageUrl) async {
    try {
      await _db
          .collection('categories')
          .doc(categoryId)
          .update({'imageUrl': newImageUrl});
    } catch (e) {
      throw Exception('Error updating category thumbnail: $e');
    }
  }

  // --- Creator Profile Methods ---
  Stream<CreatorProfile> getCreatorProfile() {
    return _db.collection('creator_profile').doc('my_profile').snapshots().map(
          (doc) => doc.exists
          ? CreatorProfile.fromFirestore(doc)
          : CreatorProfile(
        displayName: 'Charmy Craft',
        photoUrl: '',
        aboutMe: 'Tap edit to add your story!',
        socialLinks: [],
      ),
    );
  }

  Future<void> updateAboutMe(String newText) async {
    await _db
        .collection('creator_profile')
        .doc('my_profile')
        .set(
      {'aboutMe': newText},
      SetOptions(merge: true),
    );
  }

  Future<void> updateSocialLinks(List<SocialLink> links) async {
    final linksAsMaps = links.map((link) => link.toMap()).toList();
    await _db
        .collection('creator_profile')
        .doc('my_profile')
        .set(
      {'socialLinks': linksAsMaps},
      SetOptions(merge: true),
    );
  }

  Future<DocumentSnapshot> getCreatorProfileDocument() async {
    return _db.collection('creator_profile').doc('my_profile').get();
  }

  Future<void> updateCreatorProfileDetails(Map<String, dynamic> data) async {
    await _db
        .collection('creator_profile')
        .doc('my_profile')
        .set(data, SetOptions(merge: true));
  }
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(ref);
});