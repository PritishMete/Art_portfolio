// lib/state/profile_update_provider.dart

import 'dart:io';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:charmy_craft_studio/services/storage_service.dart';
import 'package:charmy_craft_studio/state/creator_profile_provider.dart';
import 'package:charmy_craft_studio/state/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ProfileUpdateNotifier(this._ref) : super(const AsyncData(null));

  // For updating the private user avatar
  Future<void> updateUserProfilePicture(File imageFile) async {
    state = const AsyncLoading();
    try {
      final user = _ref.read(authStateChangesProvider).value;
      if (user == null) throw Exception("User not logged in.");

      final storageService = _ref.read(storageServiceProvider);
      final authService = _ref.read(authServiceProvider);
      final firestoreService = _ref.read(firestoreServiceProvider);

      final oldPhotoUrl = user.photoURL ?? '';

      final newPhotoUrl = await storageService.uploadProfilePicture(user.uid, imageFile);

      await authService.updateUserPhotoUrl(newPhotoUrl);
      await firestoreService.updateUserPhotoUrl(user.uid, newPhotoUrl);

      if (oldPhotoUrl.isNotEmpty) {
        await storageService.deleteImageFromUrl(oldPhotoUrl);
      }

      _ref.invalidate(authStateChangesProvider);
      _ref.invalidate(userDataProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // For updating the public creator profile picture
  Future<void> updateCreatorPublicProfilePicture(File imageFile) async {
    state = const AsyncLoading();
    try {
      final user = _ref.read(authStateChangesProvider).value;
      if (user == null || _ref.read(userRoleProvider) != 'creator') {
        throw Exception("Only the creator can perform this action.");
      }

      final storageService = _ref.read(storageServiceProvider);
      final firestoreService = _ref.read(firestoreServiceProvider);

      final creatorProfileDoc = await firestoreService.getCreatorProfileDocument();
      final oldPhotoUrl = (creatorProfileDoc.data() as Map<String, dynamic>)['photoUrl'] ?? '';

      final newPhotoUrl = await storageService.uploadFile('creator_profile_pictures', imageFile);

      await firestoreService.updateCreatorProfileDetails({'photoUrl': newPhotoUrl});

      if (oldPhotoUrl.isNotEmpty) {
        if (oldPhotoUrl != user.photoURL) {
          await storageService.deleteImageFromUrl(oldPhotoUrl);
        }
      }

      _ref.invalidate(creatorProfileProvider);

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final profileUpdateProvider = StateNotifierProvider.autoDispose<
    ProfileUpdateNotifier, AsyncValue<void>>((ref) {
  return ProfileUpdateNotifier(ref);
});