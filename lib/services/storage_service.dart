// lib/services/storage_service.dart

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadFile(String path, File file) async {
    // ... no changes here
    final String fileId = const Uuid().v4();
    final Reference ref = _storage.ref(path).child(fileId);
    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<String> uploadProfilePicture(String userId, File file) async {
    // ... no changes here
    final Reference ref = _storage.ref('profile_pictures').child(userId);
    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});
    return await snapshot.ref.getDownloadURL();
  }

  // NEW METHOD: Deletes a file from Firebase Storage using its full URL
  Future<void> deleteImageFromUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      // It's okay if the file doesn't exist, so we can ignore not-found errors.
      if (e is FirebaseException && e.code != 'object-not-found') {
        print("Error deleting file from storage: $e");
      }
    }
  }
}

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});