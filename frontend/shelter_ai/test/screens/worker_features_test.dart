import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/providers/auth_state.dart';

// Pantallas
import 'package:shelter_ai/screens/worker_dashboard_screen.dart';
import 'package:shelter_ai/screens/refugee_list_screen.dart';
import 'package:shelter_ai/screens/shelter_list_screen.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';

void main() {
  Widget createScreen(Widget screen) {
    final auth = AuthState();
    auth.login(UserRole.worker, userId: 1, userName: "Worker");
    return AuthScope(
      state: auth,
      child: MaterialApp(
        routes: {
          '/add_refugee': (_) => const AddRefugeeScreen(),
          '/refugees': (_) => const RefugeeListScreen(),
          '/shelters': (_) => const ShelterListScreen(),
        },
        home: screen,
      ),
    );
  }

  group('Worker Features Tests (Clean)', () {
    testWidgets('WorkerDashboardScreen: Muestra stats y navega', (WidgetTester tester) async {
      ApiService.client = MockClient((request) async {
        // dashboard suele llamar a /refugees y /shelters
        return http.Response('[{"id": 1}]', 200);
      });

      await tester.pumpWidget(createScreen(const WorkerDashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Manual registration'), findsOneWidget);

      // Navegar a lista
      await tester.tap(find.text('Refugee list'));
      await tester.pumpAndSettle();
      expect(find.byType(RefugeeListScreen), findsOneWidget);
    });

    testWidgets('AddRefugeeScreen: Carga datos desde argumentos QR', (WidgetTester tester) async {
      // Simulamos argumentos QR
      final qrData = {
        'first_name': 'QRUser',
        'last_name': 'QRScan',
        'age': 40,
        'gender': 'Male'
      };

      await tester.pumpWidget(
        AuthScope(
          state: AuthState(),
          child: MaterialApp(
            home: const AddRefugeeScreen(),
          ),
        ),
      );

      // Push con argumentos
      tester.state<NavigatorState>(find.byType(Navigator)).push(
        MaterialPageRoute(
          settings: RouteSettings(arguments: qrData),
          builder: (_) => const AddRefugeeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('QRUser'), findsOneWidget);
      expect(find.textContaining('QRScan'), findsOneWidget);
    });
  });
}
