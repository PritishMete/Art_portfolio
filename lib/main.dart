// lib/main.dart

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:charmy_craft_studio/core/app_theme.dart';
import 'package:charmy_craft_studio/firebase_options.dart';
import 'package:charmy_craft_studio/widgets/animated_nav_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
   
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // We are turning off App Check enforcement for testing with friends.
  // try {
  //   await FirebaseAppCheck.instance.activate(
  //     androidProvider: kReleaseMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
  //   );
  // } catch (e) {
  //   print('⚠️ App Check initialization error: $e');
  // }

  await MobileAds.instance.initialize();

  runApp(const ProviderScope(child: CharmyCraftStudio()));
}

class CharmyCraftStudio extends ConsumerWidget {
  const CharmyCraftStudio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final themeMode = ref.watch(themeProvider);
    // final brightness = SchedulerBinding.instance.window.platformBrightness;
    // final isDarkMode = themeMode == ThemeMode.dark || (themeMode == ThemeMode.system && brightness == Brightness.dark);
    // final initialTheme = isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;

    // FIX: Forcing light theme for now.
    final initialTheme = AppTheme.lightTheme;

    return ThemeProvider(
      initTheme: initialTheme,
      builder: (context, myTheme) {
        return MaterialApp(
          title: 'Charmy Craft Studio',
          // FIX: The theme and darkTheme properties are set to always use the light theme.
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const AnimatedNavBar(),
        );
      },
    );
  }
}
