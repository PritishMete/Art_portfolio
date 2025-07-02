import 'package:flutter_riverpod/flutter_riverpod.dart';

// A simple provider to hold the state of our creator mode toggle
final creatorModeProvider = StateProvider<bool>((ref) {
  return false; // Default to false (normal user mode)
});