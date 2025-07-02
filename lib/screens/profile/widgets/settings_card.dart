import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        title: Text(
          title,
          style: GoogleFonts.lato(fontWeight: FontWeight.w600),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}