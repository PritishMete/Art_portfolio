// lib/screens/profile/select_avatar_screen.dart

import 'dart:io';
import 'dart:ui' as ui;
import 'package:avatar_plus/avatar_plus.dart';
import 'package:charmy_craft_studio/state/profile_update_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class SelectAvatarScreen extends ConsumerStatefulWidget {
  const SelectAvatarScreen({super.key});

  @override
  ConsumerState<SelectAvatarScreen> createState() => _SelectAvatarScreenState();
}

class _SelectAvatarScreenState extends ConsumerState<SelectAvatarScreen> {
  // 1. THE FIX: Expanded the list to 21 seeds for more variety.
  final List<String> avatarSeeds = const [
    'Charmy-Creator', 'Digital-Art', 'Handmade-Joy',
    'Pixel-Perfect', 'Crafty-Corner', 'Illustration-Pro',
    'Vector-Vibes', 'Studio-Magic', 'Artistic-Soul',
    'Abhra', 'John-Doe', 'Jane-Smith',
    'My-Avatar', 'User-123', 'Gaming-ID',
    'Creative-Cloud', 'Design-Master', 'Color-Palette',
    'Sketch-Book', 'Project-X', 'Test-User', 'Dream-Canvas',
    'Pixel-Sorcerer', 'Neo-Brush', 'Ink-Spire',
    'Art-Warrior', 'Craft-Wizard', 'Doodle-Dynamo', 'Neo-Vision',
    'Shade-Master', 'Vector-Freak', 'Aura-Designs', 'Pastel-Vibes',
    'Byte-Brush', 'Creative-Mindset', 'Layered-Legend', 'Frame-Crafter',
    'Magenta-Muse', 'Glow-Artist', 'Line-Craze', 'Fusion-Palette',
    'Aesthetic-Vision', 'Render-Realm', 'Brush-Stroke', 'Alpha-Painter',
    'Illustrio', 'Quantum-Creator', 'Figma-Fanatic', 'Retro-Dreamer',
    'Sketchstorm', 'Hue-Hacker', 'Artizen', 'Craft-Catalyst',
    'Inspiro-Maker', 'Mystic-Pixel', 'Vision-Bender', 'Canvas-Nomad'
  ];

  int? _selectedIndex;

  Future<void> _onAvatarSelected(String seed, int index) async {
    setState(() {
      _selectedIndex = index;
    });

    try {
      // 2. THE FIX: Added `trBackground: true` to generate without a background.
      final svgString = AvatarPlusGen.instance.generate(seed, trBackground: false);

      final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), null);
      final image = await pictureInfo.picture.toImage(235, 235);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception("Could not convert avatar to PNG.");

      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$seed.png');
      await file.writeAsBytes(pngBytes);

      await ref.read(profileUpdateProvider.notifier).updateUserProfilePicture(file);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select avatar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _selectedIndex = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select an Avatar', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: avatarSeeds.length,
        itemBuilder: (context, index) {
          final seed = avatarSeeds[index];
          final bool isLoading = _selectedIndex == index;

          return GestureDetector(
            onTap: isLoading ? null : () => _onAvatarSelected(seed, index),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isLoading ? Theme.of(context).colorScheme.secondary : Colors.transparent,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.secondary))
                  : AvatarPlus(seed),
            ),
          );
        },
      ),
    );
  }
}