// lib/screens/appointment/appointment_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book an Appointment',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.displayLarge?.color,
          ),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Appointment booking feature to be implemented.'),
      ),
    );
  }
}