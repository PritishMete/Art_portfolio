// lib/state/upload_provider.dart

import 'dart:io';
import 'package:charmy_craft_studio/core/app_theme.dart';
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:charmy_craft_studio/services/storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';

@immutable
class UploadState {
  final List<File> originalFiles;
  final File? thumbnailFile;
  final bool isLoading;
  final String? errorMessage;
  final double progress;

  const UploadState({
    this.originalFiles = const [],
    this.thumbnailFile,
    this.isLoading = false,
    this.errorMessage,
    this.progress = 0.0,
  });

  UploadState copyWith({
    List<File>? originalFiles,
    File? thumbnailFile,
    bool? isLoading,
    String? errorMessage,
    double? progress,
    bool clearThumbnail = false,
  }) {
    return UploadState(
      originalFiles: originalFiles ?? this.originalFiles,
      thumbnailFile: clearThumbnail ? null : thumbnailFile ?? this.thumbnailFile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }
}

class UploadNotifier extends StateNotifier<UploadState> {
  final Ref _ref;
  UploadNotifier(this._ref) : super(const UploadState());

  Future<void> pickImages({required bool allowMultiple}) async {
    reset();
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFiles = result.paths.map((path) => File(path!)).toList();
      state = state.copyWith(originalFiles: pickedFiles);

      if (pickedFiles.isNotEmpty) {
        final cropper = ImageCropper();
        final CroppedFile? croppedFile = await cropper.cropImage(
          sourcePath: pickedFiles.first.path,
          aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Thumbnail',
                toolbarColor: AppTheme.lightTheme.colorScheme.secondary,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
            IOSUiSettings(title: 'Crop Thumbnail', aspectRatioLockEnabled: true),
          ],
        );

        if (croppedFile != null) {
          state = state.copyWith(thumbnailFile: File(croppedFile.path));
        }
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> uploadArtwork({
    required String title,
    required String tags,
    required String category,
    required Map<String, dynamic> dimensions,
    required String description,
    required double price,
    required bool isFree,
    required bool isDownloadable, // NEW
  }) async {
    if (state.originalFiles.isEmpty || state.thumbnailFile == null) {
      state = state.copyWith(errorMessage: 'Error: Files not ready.');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final storageService = _ref.read(storageServiceProvider);
      final firestoreService = _ref.read(firestoreServiceProvider);
      final user = _ref.read(authStateChangesProvider).value;

      if (user == null) throw Exception('User not logged in.');

      final thumbnailUrl = await storageService.uploadFile('artworks/thumbnail', state.thumbnailFile!);

      List<String> imageUrls = [];
      await Future.forEach(state.originalFiles, (file) async {
        final url = await storageService.uploadFile('artworks/original', file as File);
        imageUrls.add(url);
      });

      final newArtwork = Artwork(
        id: '',
        title: title,
        artist: user.uid,
        imageUrls: imageUrls,
        thumbnailUrl: thumbnailUrl,
        category: category,
        tags: tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        dimensions: dimensions,
        description: description,
        price: price,
        isFree: isFree,
        createdAt: DateTime.now(),
        isDownloadable: isDownloadable, // NEW
      );

      await firestoreService.addArtwork(newArtwork);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateArtwork({
    required String artworkId,
    required String title,
    required String tags,
    required String category,
    required Map<String, dynamic> dimensions,
    required String description,
    required double price,
    required bool isFree,
    required bool isDownloadable, // NEW
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final firestoreService = _ref.read(firestoreServiceProvider);
      final user = _ref.read(authStateChangesProvider).value;

      if (user == null) throw Exception('User not logged in.');

      final docToUpdate = await FirebaseFirestore.instance.collection('artworks').doc(artworkId).get();
      final existingData = docToUpdate.data() as Map<String, dynamic>;

      final updatedArtwork = Artwork(
        id: artworkId,
        title: title,
        artist: user.uid,
        imageUrls: List<String>.from(existingData['imageUrls'] ?? []),
        thumbnailUrl: existingData['thumbnailUrl'] ?? '',
        category: category,
        tags: tags.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        dimensions: dimensions,
        description: description,
        price: price,
        isFree: isFree,
        createdAt: (existingData['createdAt'] as Timestamp).toDate(),
        isArchived: existingData['isArchived'] ?? false,
        isDownloadable: isDownloadable, // NEW
      );

      await firestoreService.updateArtwork(updatedArtwork);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void reset() {
    state = const UploadState();
  }
}

final uploadProvider = StateNotifierProvider.autoDispose<UploadNotifier, UploadState>((ref) {
  return UploadNotifier(ref);
});