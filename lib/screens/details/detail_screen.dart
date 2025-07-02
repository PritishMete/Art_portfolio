// lib/screens/details/detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/screens/auth/login_screen.dart'; // Import the new LoginScreen
import 'package:charmy_craft_studio/screens/details/full_image_screen.dart';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:charmy_craft_studio/services/download_service.dart';
import 'package:charmy_craft_studio/state/favorites_provider.dart';
import 'package:charmy_craft_studio/state/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:like_button/like_button.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Artwork artwork;

  const DetailScreen({super.key, required this.artwork});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        setState(() => _currentPage = _pageController.page!.round());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildMainActionButton(
      BuildContext context, WidgetRef ref, Artwork artwork) {
    if (!artwork.isDownloadable) {
      return const SizedBox.shrink();
    }

    void navigateToLogin() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }

    if (artwork.isFree) {
      return ElevatedButton.icon(
        icon: _isDownloading
            ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.download_for_offline_outlined),
        label: Text(_isDownloading ? 'Downloading...' : 'Download Now'),
        onPressed: _isDownloading
            ? null
            : () async {
          final user = ref.read(authStateChangesProvider).value;
          if (user == null) {
            navigateToLogin();
            return;
          }

          setState(() => _isDownloading = true);
          final downloader = ref.read(downloadServiceProvider);
          final success = await downloader.downloadAndSaveImages(
              artwork.imageUrls, "Charmi Crafts");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                Text(success ? 'Image saved!' : 'Download failed.'),
                action: success
                    ? SnackBarAction(
                  label: 'OPEN',
                  onPressed: () => Gal.open(),
                )
                    : null,
              ),
            );
            setState(() => _isDownloading = false);
          }
        },
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            textStyle:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );
    }

    return ElevatedButton.icon(
      icon: const Icon(Icons.add_shopping_cart_outlined),
      label: Text('Add to Cart (\$${artwork.price.toStringAsFixed(2)})'),
      onPressed: () {
        final user = ref.read(authStateChangesProvider).value;
        if (user == null) {
          navigateToLogin();
          return;
        }
        /* TODO: Add to cart logic */
      },
      style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          textStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFavorite =
        ref.watch(favoriteIdsProvider).value?.contains(widget.artwork.id) ??
            false;
    final artwork = widget.artwork;
    final pxDimensions = artwork.dimensions['px'] ?? {};
    final width = pxDimensions['width']?.toString() ?? 'N/A';
    final height = pxDimensions['height']?.toString() ?? 'N/A';
    final displaySize =
    (width.isNotEmpty && height.isNotEmpty) ? '$width x $height px' : 'N/A';

    void navigateToLogin() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: artwork.imageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = artwork.imageUrls[index];
                return Hero(
                  tag: artwork.id + index.toString(),
                  child: _buildImage(imageUrl, index),
                );
              },
            ),
          ),
          if (artwork.imageUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.45 + 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    artwork.imageUrls.length,
                        (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 12 : 8,
                        height: _currentPage == i ? 12 : 8,
                        decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle))),
              ),
            ),
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder:
                (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 20)
                    ]),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                  children: [
                    Center(
                        child: Container(
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 24),
                    Text(artwork.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.displayLarge?.color)),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final artistAsync =
                        ref.watch(artistDetailsProvider(artwork.artist));
                        return Center(
                            child: artistAsync.when(
                                data: (artistData) => Text(
                                    'by ${artistData?.displayName ?? 'Unknown Artist'}',
                                    style: GoogleFonts.lato(
                                        fontSize: 18,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey[700])),
                                loading: () => const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                                error: (err, stack) =>
                                const Text('by Unknown Artist')));
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined,
                            color: theme.colorScheme.secondary, size: 16),
                        const SizedBox(width: 8),
                        Text(artwork.category, style: theme.textTheme.bodyLarge),
                        const SizedBox(width: 24),
                        Icon(Icons.aspect_ratio_outlined,
                            color: theme.colorScheme.secondary, size: 16),
                        const SizedBox(width: 8),
                        Text(displaySize, style: theme.textTheme.bodyLarge),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text('Description',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        artwork.description.isEmpty
                            ? "No description provided."
                            : artwork.description,
                        style: GoogleFonts.lato(fontSize: 16, height: 1.5)),
                    const SizedBox(height: 32),
                    _buildMainActionButton(context, ref, artwork),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop())),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle),
              child: LikeButton(
                size: 24,
                isLiked: isFavorite,
                circleColor: const CircleColor(
                    start: Color(0xfff06292), end: Color(0xfff8bbd0)),
                bubblesColor: const BubblesColor(
                    dotPrimaryColor: Color(0xfff48fb1),
                    dotSecondaryColor: Color(0xfffce4ec)),
                likeBuilder: (bool isLiked) => Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.redAccent : Colors.white,
                    size: 24),
                onTap: (bool isLiked) async {
                  final user = ref.read(authStateChangesProvider).value;
                  if (user == null) {
                    navigateToLogin();
                    return null; // Don't toggle the like state
                  }
                  await ref
                      .read(favoritesNotifierProvider.notifier)
                      .toggleFavorite(artwork);
                  return !isLiked;
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl, int index) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.7),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, _, __) =>
            FullImageScreen(imageUrls: widget.artwork.imageUrls, initialIndex: index),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      )),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
        const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => Container(
            color: Colors.grey[850],
            child: const Center(child: Icon(Icons.error, color: Colors.white))),
      ),
    );
  }
}