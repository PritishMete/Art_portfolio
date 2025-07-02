// lib/screens/creator/creator_uploads_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/screens/details/detail_screen.dart';
import 'package:charmy_craft_studio/screens/upload/upload_artwork_screen.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:charmy_craft_studio/state/creator_uploads_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatorUploadsScreen extends ConsumerStatefulWidget {
  const CreatorUploadsScreen({super.key});

  @override
  ConsumerState<CreatorUploadsScreen> createState() =>
      _CreatorUploadsScreenState();
}

class _CreatorUploadsScreenState extends ConsumerState<CreatorUploadsScreen> {
  String _searchQuery = '';
  DateTimeRange? _selectedDateRange;

  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange ?? initialRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
    }
  }

  void _confirmAction({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: title.toLowerCase().contains('delete')
                  ? Colors.red
                  : null,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final artworksAsync = ref.watch(creatorArtworksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Uploads',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _selectDateRange(context),
            tooltip: 'Filter by Date Range',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by title or description...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty || _selectedDateRange != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _selectedDateRange = null;
                        });
                      },
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear Filters'),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: artworksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (artworks) {
                final filteredArtworks = artworks.where((art) {
                  final matchesQuery =
                      _searchQuery.isEmpty ||
                      art.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      art.description.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      );

                  final matchesDateRange =
                      _selectedDateRange == null ||
                      (art.createdAt.isAfter(
                            _selectedDateRange!.start.subtract(
                              const Duration(days: 1),
                            ),
                          ) &&
                          art.createdAt.isBefore(
                            _selectedDateRange!.end.add(
                              const Duration(days: 1),
                            ),
                          ));

                  return matchesQuery && matchesDateRange;
                }).toList();

                if (filteredArtworks.isEmpty) {
                  return const Center(child: Text('No artworks found.'));
                }

                return ListView.builder(
                  itemCount: filteredArtworks.length,
                  itemBuilder: (context, index) {
                    final artwork = filteredArtworks[index];
                    return _buildArtworkCard(context, artwork);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkCard(BuildContext context, Artwork artwork) {
    // We get the service here to use in the buttons
    final firestoreService = ref.read(firestoreServiceProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: artwork.thumbnailUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artwork.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        artwork.category,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (artwork.isArchived)
                        const Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Chip(
                            label: Text('Archived'),
                            labelStyle: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.blueGrey,
                            padding: EdgeInsets.symmetric(horizontal: 4),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Tooltip(
                  message: 'Visit',
                  child: IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(artwork: artwork),
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Edit',
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            UploadArtworkScreen(artworkToEdit: artwork),
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: artwork.isArchived ? 'Unarchive' : 'Archive',
                  child: IconButton(
                    icon: Icon(
                      artwork.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () => _confirmAction(
                      context: context,
                      title: artwork.isArchived
                          ? 'Unarchive Artwork?'
                          : 'Archive Artwork?',
                      content: artwork.isArchived
                          ? 'This will make the artwork public again.'
                          : 'This will hide the artwork from the public discover page.',
                      onConfirm: () =>
                          firestoreService.setArtworkArchivedStatus(
                            artwork.id,
                            !artwork.isArchived,
                          ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Remove',
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.red,
                    ),
                    onPressed: () => _confirmAction(
                      context: context,
                      title: 'Delete this artwork?',
                      content: 'This action is permanent and cannot be undone.',
                      // THIS IS THE CORRECTED LINE
                      onConfirm: () => firestoreService.deleteArtwork(artwork),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
