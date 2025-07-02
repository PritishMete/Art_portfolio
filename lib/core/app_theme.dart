// lib/core/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _lightPrimaryColor = Colors.white;
  static const Color _lightOnPrimaryColor = Colors.black;
  static const Color _lightBackgroundColor = Color(0xFFF7F7F7);
  static const Color _accentColor = Color(0xFFF57C00); // Our app's orange accent

  static const Color _darkPrimaryColor = Color(0xFF121212);
  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkBackgroundColor = Color(0xFF1E1E1E);

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: _lightBackgroundColor,
    primaryColor: _lightPrimaryColor,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      onPrimary: _lightOnPrimaryColor,
      secondary: _accentColor,
      surface: Colors.white,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _accentColor,
      selectionColor: _accentColor.withOpacity(0.3),
      selectionHandleColor: _accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _lightBackgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: _lightOnPrimaryColor),
      titleTextStyle: GoogleFonts.lato(
        color: _lightOnPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme().apply(
      bodyColor: _lightOnPrimaryColor,
      displayColor: _lightOnPrimaryColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _accentColor,
      unselectedItemColor: Colors.grey,
    ),
    // ** THE FIX IS HERE **
    cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: _darkBackgroundColor,
    primaryColor: _darkPrimaryColor,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      onPrimary: _darkOnPrimaryColor,
      secondary: _accentColor,
      surface: _darkPrimaryColor,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: _accentColor,
      selectionColor: _accentColor.withOpacity(0.5),
      selectionHandleColor: _accentColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _darkBackgroundColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: _darkOnPrimaryColor),
      titleTextStyle: GoogleFonts.lato(
        color: _darkOnPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: GoogleFonts.latoTextTheme().apply(
      bodyColor: _darkOnPrimaryColor,
      displayColor: _darkOnPrimaryColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: _accentColor,
      unselectedItemColor: Colors.grey,
    ),
    // ** THE FIX IS HERE **
    cardTheme: CardThemeData( // Changed from CardTheme to CardThemeData
      color: _darkPrimaryColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}