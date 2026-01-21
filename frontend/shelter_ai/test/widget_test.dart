import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/main.dart';
import 'package:shelter_ai/services/api_service.dart';

void main() {
  testWidgets('Main app boots and shows entry screen or redirects when authenticated',
      (WidgetTester tester) async {
    // Mock para evitar llamadas reales a la API (por si alguna pantalla lo usa)
    ApiService.client = MockClient((request) async {
      return http.Response(json.encode([]), 200);
    });

    await tester.pumpWidget(const ShelterAIApp());
    await tester.pumpAndSettle();

    // ✅ Caso 1: WelcomeScreen (sin sesión)
    final isWelcome = find.text('We help you find a safe place.').evaluate().isNotEmpty &&
        find.text('I am a refugee').evaluate().isNotEmpty &&
        find.text('I am a worker').evaluate().isNotEmpty;

    // ✅ Caso 2: Redirección si ya estaba autenticado (por otros tests)
    final isWorkerDashboard = find.text('Reception Panel').evaluate().isNotEmpty;
    final isRefugeeProfile = find.text('Your safe space').evaluate().isNotEmpty;

    expect(
      isWelcome || isWorkerDashboard || isRefugeeProfile,
      true,
      reason:
          'No se detectó WelcomeScreen ni pantallas de redirección (Reception Panel / Your safe space).',
    );
  });
}
