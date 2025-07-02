// lib/services/download_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart'; // UPDATED IMPORT
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DownloadService {
  final Dio _dio = Dio();

  Future<bool> downloadAndSaveImages(List<String> imageUrls, String albumName) async {
    try {
      // First, request permissions if not already granted.
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final accessGranted = await Gal.requestAccess();
        if (!accessGranted) {
          print("Gallery access was denied by the user.");
          return false;
        }
      }

      for (final url in imageUrls) {
        // Create a unique file name
        final fileName = "charmy_craft_${DateTime.now().millisecondsSinceEpoch}.jpg";
        // Get the temporary directory to save the file
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/$fileName';

        // Download the image file
        await _dio.download(url, path);

        // Save the downloaded file to the gallery using the 'gal' package
        await Gal.putImage(path, album: albumName);

        // Clean up the temporary file
        await File(path).delete();
      }
      return true;
    } catch (e) {
      print("Download error: $e");
      return false;
    }
  }
}

final downloadServiceProvider = Provider((ref) => DownloadService());