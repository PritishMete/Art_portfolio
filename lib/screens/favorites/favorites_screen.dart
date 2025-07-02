// lib/screens/favorites/favorites_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/screens/details/detail_screen.dart';
import 'package:charmy_craft_studio/state/favorites_provider.dart';
import 'package:charmy_craft_studio/state/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // A local list to track items for animation purposes
  List<Artwork> _localFavorites = [];

  // A flag to ensure we only populate the list once from the initial data
  bool _isListInitialized = false;

  void _removeItem(int index, Artwork artwork) {
    // 1. Remove the item from our local list
    final removedItem = _localFavorites.removeAt(index);

    // 2. Trigger the animation on the AnimatedList
    _listKey.currentState?.removeItem(
      index,
          (context, animation) => _buildAnimatedItem(removedItem, animation),
      duration: const Duration(milliseconds: 400),
    );

    // 3. After starting the animation, update the database
    Future.delayed(const Duration(milliseconds: 100), () {
      ref.read(favoritesNotifierProvider.notifier).toggleFavorite(artwork);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (favoriteArtworks) {
          // This populates our local list with the initial data from the database
          if (!_isListInitialized) {
            _localFavorites = List.from(favoriteArtworks);
            _isListInitialized = true;
          }

          if (_localFavorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No favorites yet', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.grey[400])),
                  Text('Tap the heart on an artwork to save it.', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[400])),
                ],
              ),
            );
          }

          return AnimatedList(
            key: _listKey,
            initialItemCount: _localFavorites.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, index, animation) {
              final artwork = _localFavorites[index];
              return _buildAnimatedItem(artwork, animation, index: index);
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedItem(Artwork artwork, Animation<double> animation, {int? index}) {
    // Use the animation provided by AnimatedList to create the transitions
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailScreen(artwork: artwork)),
              );
            },
            leading: SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: artwork.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            title: Text(artwork.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Consumer(
              builder: (context, ref, child) {
                final artistAsync = ref.watch(artistDetailsProvider(artwork.artist));
                return artistAsync.when(
                  data: (artist) => Text(artist?.displayName ?? 'Unknown Artist'),
                  error: (e, s) => const Text('...'),
                  loading: () => const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                // We must have the index to remove the item from the list
                if (index != null) {
                  _removeItem(index, artwork);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}