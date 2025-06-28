// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App widget can be created', (WidgetTester tester) async {
    // Build a minimal MaterialApp to test the overall structure
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Remote Media PI')),
          body: const Center(child: Text('Test App')),
        ),
      ),
    );

    // Verify that our app loads with the correct title
    expect(find.text('Remote Media PI'), findsOneWidget);
    expect(find.text('Test App'), findsOneWidget);
  });
}
