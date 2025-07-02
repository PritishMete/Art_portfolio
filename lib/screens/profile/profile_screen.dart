// lib/screens/profile/profile_screen.dart

import 'dart:io';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:charmy_craft_studio/core/app_theme.dart';
import 'package:charmy_craft_studio/models/user.dart';
import 'package:charmy_craft_studio/screens/auth/login_screen.dart';
import 'package:charmy_craft_studio/screens/creator/creator_uploads_screen.dart';
import 'package:charmy_craft_studio/screens/creator/manage_categories_screen.dart';
import 'package:charmy_craft_studio/screens/profile/select_avatar_screen.dart';
import 'package:charmy_craft_studio/screens/profile/widgets/settings_card.dart';
import 'package:charmy_craft_studio/screens/upload/upload_artwork_screen.dart';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:charmy_craft_studio/services/firestore_service.dart';
import 'package:charmy_craft_studio/state/profile_update_provider.dart';
import 'package:charmy_craft_studio/state/theme_provider.dart';
import 'package:charmy_craft_studio/state/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:widget_circular_animator/widget_circular_animator.dart';

void showAuthModal(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showChangePictureOptions(BuildContext context, WidgetRef ref, String userRole) async {
    if (userRole != 'creator') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only creators can set a public profile picture.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Change Profile Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.of(dialogContext).pop();
                  try {
                    final picker = ImagePicker();
                    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

                    if (pickedFile != null) {
                      final cropper = ImageCropper();
                      final CroppedFile? croppedFile = await cropper.cropImage(
                        sourcePath: pickedFile.path,
                        uiSettings: [
                          AndroidUiSettings(
                            toolbarTitle: 'Crop Picture',
                            toolbarColor: Theme.of(context).colorScheme.secondary,
                            toolbarWidgetColor: Colors.white,
                            lockAspectRatio: false,
                            cropStyle: CropStyle.circle,
                          ),
                          IOSUiSettings(
                            title: 'Crop Picture',
                            aspectRatioLockEnabled: false,
                            cropStyle: CropStyle.circle,
                            resetAspectRatioEnabled: true,
                          ),
                        ],
                      );

                      if (croppedFile != null) {
                        final imageFile = File(croppedFile.path);
                        await ref.read(profileUpdateProvider.notifier).updateUserProfilePicture(imageFile);
                      }
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to process image: $e')));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.face_retouching_natural_outlined),
                title: const Text('Select an Avatar'),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SelectAvatarScreen()),
                  );
                },
              ),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel'))],
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final nameController = TextEditingController(text: user.displayName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Change Display Name'),
              content: Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'New Name', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter a name.' : null,
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                isSaving
                    ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setDialogState(() => isSaving = true);
                      try {
                        final newName = nameController.text.trim();
                        await ref.read(authServiceProvider).updateUserDisplayName(newName);
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                          );
                        }
                      } finally {
                        if (context.mounted) setDialogState(() => isSaving = false);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userData = ref.watch(userDataProvider);
    final userRole = ref.watch(userRoleProvider);
    final isUploading = ref.watch(profileUpdateProvider).isLoading;

    ref.listen<AsyncValue<void>>(profileUpdateProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${state.error}'), backgroundColor: Colors.red),
        );
      }
    });

    return ThemeSwitchingArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('My Profile', style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: userData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (user) {
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("You're not signed in."),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)
                      ),
                      child: const Text('Sign In / Sign Up'),
                      onPressed: () {
                        showAuthModal(context);
                      },
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => _showChangePictureOptions(context, ref, userRole),
                        child: WidgetCircularAnimator(
                          size: 150,
                          innerColor: theme.colorScheme.secondary,
                          outerColor: theme.colorScheme.secondary.withOpacity(0.5),
                          child: Center(
                            child: isUploading
                                ? const CircularProgressIndicator()
                                : CircleAvatar(
                              radius: 65,
                              backgroundColor: theme.colorScheme.surface,
                              child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                  ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.photoUrl!,
                                  fit: BoxFit.cover,
                                  width: 130,
                                  height: 130,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 60),
                                ),
                              )
                                  : Icon(Icons.person, size: 60, color: theme.colorScheme.secondary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.displayName ?? 'Charmy User',
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, size: 20, color: Colors.grey[600]),
                            splashRadius: 20,
                            onPressed: () => _showEditNameDialog(context, ref, user),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(user.email, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                      if (userRole == 'creator')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Chip(
                            label: const Text('Creator'),
                            backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
                            labelStyle: TextStyle(color: theme.colorScheme.secondary),
                            side: BorderSide.none,
                          ),
                        ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, curve: Curves.easeOut),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        _buildSectionHeader('Settings'),
                        const SizedBox(height: 8),
                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: theme.dividerColor)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // FIX: Commenting out the theme switcher UI for now
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //   children: [
                                //     Text('Theme', style: theme.textTheme.titleMedium),
                                //     ThemeSwitcher(
                                //       builder: (context) {
                                //         final themeNotifier = ref.read(themeProvider.notifier);
                                //         final currentTheme = ref.watch(themeProvider);
                                //         return AnimatedToggleSwitch<ThemeMode>.rolling(
                                //           current: currentTheme,
                                //           values: const [ThemeMode.light, ThemeMode.system, ThemeMode.dark],
                                //           onChanged: (newTheme) {
                                //             themeNotifier.setTheme(newTheme);
                                //             final brightness = MediaQuery.of(context).platformBrightness;
                                //             final isDark = newTheme == ThemeMode.dark || (newTheme == ThemeMode.system && brightness == Brightness.dark);
                                //             ThemeSwitcher.of(context).changeTheme(
                                //               theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
                                //             );
                                //           },
                                //           iconBuilder: (value, foreground) {
                                //             IconData data;
                                //             switch (value) {
                                //               case ThemeMode.light: data = Icons.wb_sunny_outlined; break;
                                //               case ThemeMode.system: data = Icons.phone_iphone_outlined; break;
                                //               case ThemeMode.dark: data = Icons.nightlight_outlined; break;
                                //             }
                                //             return Icon(data, color: foreground ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color, size: 18);
                                //           },
                                //           style: ToggleStyle(borderColor: Colors.transparent, indicatorColor: theme.cardColor, backgroundColor: theme.scaffoldBackgroundColor),
                                //         );
                                //       },
                                //     )
                                //   ],
                                // ),
                                // const Divider(height: 24),
                                if (userRole == 'creator') ...[
                                  SettingsCard(
                                    icon: Icons.upload_file_outlined,
                                    title: 'Upload New Artwork',
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UploadArtworkScreen())),
                                  ),
                                  const Divider(height: 1),
                                  SettingsCard(
                                    icon: Icons.collections_bookmark_outlined,
                                    title: 'All Uploads',
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreatorUploadsScreen())),
                                  ),
                                  const Divider(height: 1),
                                  SettingsCard(
                                    icon: Icons.category_outlined,
                                    title: 'Manage Galleries',
                                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageCategoriesScreen())),
                                  ),
                                  const Divider(height: 24),
                                ],
                                SettingsCard(icon: Icons.shopping_bag_outlined, title: 'My Orders', onTap: () {}),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            onPressed: () => ref.read(authServiceProvider).signOut(),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
      ),
    );
  }
}