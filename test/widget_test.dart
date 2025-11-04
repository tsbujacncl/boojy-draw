// Basic Flutter widget test for Boojy Draw

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boojy_draw/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: BoojyDrawApp(),
      ),
    );

    // Verify that the app title is present
    expect(find.text('Boojy Draw'), findsOneWidget);

    // Verify that the app shell is rendered
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
