// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:charmy_craft_studio/main.dart';
import 'package:charmy_craft_studio/widgets/animated_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App starts and shows the main navigation bar', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CharmyCraftStudio()));

    // Verify that the main navigation bar is present.
    // This confirms the app has started correctly.
    expect(find.byType(AnimatedNavBar), findsOneWidget);

    // You can also verify that the home icon is present as a basic check
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}