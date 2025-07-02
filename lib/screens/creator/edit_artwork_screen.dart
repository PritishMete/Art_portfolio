// lib/screens/creator/edit_artwork_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charmy_craft_studio/models/artwork.dart';

class EditArtworkScreen extends ConsumerStatefulWidget {
  final Artwork artwork;

  const EditArtworkScreen({super.key, required this.artwork});

  @override
  ConsumerState<EditArtworkScreen> createState() => _EditArtworkScreenState();
}

class _EditArtworkScreenState extends ConsumerState<EditArtworkScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _thumbnailUrlController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.artwork.title);
    _descriptionController = TextEditingController(text: widget.artwork.description);
    _categoryController = TextEditingController(text: widget.artwork.category);
    _thumbnailUrlController = TextEditingController(text: widget.artwork.thumbnailUrl);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // Call your provider update logic here (to be implemented)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Changes saved successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Artwork')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _thumbnailUrlController,
              decoration: const InputDecoration(labelText: 'Thumbnail URL'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Save Changes'),
            )
          ],
        ),
      ),
    );
  }
}
