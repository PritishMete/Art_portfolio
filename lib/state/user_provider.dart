// lib/state/user_provider.dart

import 'package:charmy_craft_studio/models/user.dart';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This provider fetches the full UserModel from Firestore for the current user
final userDataProvider = FutureProvider<UserModel?>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);

  final user = authState.value;
  if (user != null) {
    return await firestoreService.getUser(user.uid);
  }
  return null;
});

// A simpler provider that just returns the current user's role as a string.
final userRoleProvider = Provider<String>((ref) {
  final userData = ref.watch(userDataProvider);
  return userData.value?.role ?? 'user';
});

// This provider can fetch a specific user's data by their ID.
// The ".family" modifier allows us to pass in the artist's ID.
final artistDetailsProvider = FutureProvider.family<UserModel?, String>((ref, artistId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUser(artistId);
});