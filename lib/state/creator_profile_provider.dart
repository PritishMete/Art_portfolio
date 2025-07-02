// lib/state/creator_profile_provider.dart

import 'package:charmy_craft_studio/models/creator_profile.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final creatorProfileProvider = StreamProvider<CreatorProfile>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getCreatorProfile();
});