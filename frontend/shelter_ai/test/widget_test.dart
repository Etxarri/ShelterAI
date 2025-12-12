// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:shelter_ai/main.dart';

void main() {
  testWidgets('Main app shows home welcome and add button', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const ShelterAIApp());
    // Wait for any async builders to finish
    await tester.pumpAndSettle();

    // Verify welcome text and a primary action button exist
    expect(find.text('Bienvenido a ShelterAI'), findsOneWidget);
    expect(find.text('Añadir refugiado'), findsOneWidget);
  });
}
