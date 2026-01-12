import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:shelter_ai/main.dart';
import 'package:shelter_ai/services/api_service.dart';

void main() {
  testWidgets('Main app shows home welcome and add button', (WidgetTester tester) async {
    // Setup mock para evitar llamadas reales a la API
    final mockClient = MockClient((request) async {
      return http.Response(json.encode([]), 200);
    });
    ApiService.client = mockClient;

    // Build the app
    await tester.pumpWidget(const ShelterAIApp());
    // Wait for any async builders to finish
    await tester.pumpAndSettle();

    // Verify welcome text and a primary action button exist
    expect(find.text('Welcome to ShelterAI'), findsOneWidget);
    expect(find.text('Add Refugee'), findsOneWidget);
  });
}
