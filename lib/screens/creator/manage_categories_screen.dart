// lib/screens/creator/manage_categories_screen.dart
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charmy_craft_studio/models/category.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:charmy_craft_studio/services/storage_service.dart';
import 'package:charmy_craft_studio/state/categories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _updateCategoryImage(BuildContext context, WidgetRef ref, CategoryModel category) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Uploading image...')));

      try {
        final storageService = ref.read(storageServiceProvider);
        final firestoreService = ref.read(firestoreServiceProvider);

        // Upload the new image
        final newImageUrl = await storageService.uploadFile('category_thumbnails', imageFile);

        // FIX: Before updating, check for an old image URL and delete it
        if (category.imageUrl.isNotEmpty) {
          await storageService.deleteImageFromUrl(category.imageUrl);
        }

        // Now, update the category document in Firestore with the new URL
        await firestoreService.updateCategoryThumbnail(category.id, newImageUrl);

        ref.invalidate(categoriesProvider);

        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Thumbnail updated!'), backgroundColor: Colors.green));

      } catch (e) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Galleries', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text('No categories found. Add one from the upload screen.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundImage: category.imageUrl.isNotEmpty
                        ? CachedNetworkImageProvider(category.imageUrl)
                        : null,
                    child: category.imageUrl.isEmpty
                        ? Icon( (category.name == "All") ? Icons.collections_bookmark_outlined : Icons.image_not_supported )
                        : null,
                  ),
                  title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(category.imageUrl.isEmpty ? 'Tap to add thumbnail' : 'Tap to change thumbnail'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _updateCategoryImage(context, ref, category),
                ),
              );
            },
          );
        },
      ),
    );
  }
}