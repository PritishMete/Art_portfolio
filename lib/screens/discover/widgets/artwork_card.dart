// lib/screens/discover/widgets/artwork_card.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:charmy_craft_studio/models/artwork.dart';
import 'package:charmy_craft_studio/screens/details/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ArtworkCard extends ConsumerWidget {
  final Artwork artwork;

  const ArtworkCard({super.key, required this.artwork});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(artwork: artwork),
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Hero(
                tag: artwork.id,
                child: CachedNetworkImage(
                  imageUrl: artwork.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[850],
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Theme.of(context).cardColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artwork.title,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        artwork.category,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        artwork.isFree
                            ? 'Free'
                            : '\$${artwork.price.toStringAsFixed(0)}',
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}