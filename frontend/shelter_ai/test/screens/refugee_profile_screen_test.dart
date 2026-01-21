import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/main.dart'; // AuthScope
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/refugee_profile_screen.dart';
import 'package:shelter_ai/screens/recommendation_selection_screen.dart';
import 'package:shelter_ai/services/api_service.dart';

void main() {
  // Helper: app con Auth + rutas necesarias
  Widget wrapWithAuth({
    required AuthState auth,
    required Widget child,
    Map<String, WidgetBuilder>? routes,
    NavigatorObserver? observer,
  }) {
    return AuthScope(
      state: auth,
      child: MaterialApp(
        home: child,
        routes: {
          '/login': (_) => const Scaffold(body: Text('Login Screen')),
          '/refugee-self-form-qr': (_) => const Scaffold(body: Text('Self QR Screen')),
          ...?routes,
        },
        navigatorObservers: observer != null ? [observer] : const [],
      ),
    );
  }

  group('RefugeeProfileScreen coverage', () {
    testWidgets('Renderiza info basica y botones', (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee, userId: 10, userName: 'Aiman');

      ApiService.client = MockClient((request) async {
        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Your safe space'), findsOneWidget);
      expect(find.textContaining('Hello, we are with you'), findsOneWidget);
      expect(find.textContaining('ID: 10'), findsOneWidget);

      expect(find.text('Check assignment and choose shelter'), findsOneWidget);
      expect(find.text('View or generate my QR'), findsOneWidget);
      expect(find.text('What will happen upon arrival'), findsOneWidget);
      expect(find.text('Request help now'), findsOneWidget);
    });

    testWidgets('Logout navega a /login', (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee, userId: 10, userName: 'Aiman');

      ApiService.client = MockClient((request) async {
        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      // Tap icon logout
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('Check assignment: refugeeId null -> muestra error', (tester) async {
      final auth = AuthState();
      // Importante: NO login => userId null

      ApiService.client = MockClient((request) async {
        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check assignment and choose shelter'));
      await tester.pumpAndSettle();

      expect(find.text('Refugee ID not found in session.'), findsOneWidget);
    });

    testWidgets('Check assignment: has_assignment false -> muestra info', (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee, userId: 55, userName: 'Refugee');

      ApiService.client = MockClient((request) async {
        final url = request.url.toString().toLowerCase();

        // Endpoint de "assignment check"
        if (url.contains('assignment')) {
          return http.Response(json.encode({'has_assignment': false}), 200);
        }

        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check assignment and choose shelter'));
      await tester.pumpAndSettle();

      expect(find.text('You have not yet been assigned to any shelter.'), findsOneWidget);
    });

    testWidgets('Check assignment: API lanza exception -> muestra error', (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee, userId: 77, userName: 'Refugee');

      ApiService.client = MockClient((request) async {
        final url = request.url.toString().toLowerCase();

        if (url.contains('assignment')) {
          return http.Response('Internal error', 500);
        }

        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Check assignment and choose shelter'));
      await tester.pumpAndSettle();

      // El texto exacto incluye el Exception, así que buscamos por "Error checking assignment"
      expect(find.textContaining('Error checking assignment:'), findsOneWidget);
    });

    testWidgets(
      'Check assignment: has_assignment true -> navega a RecommendationSelectionScreen y al volver true muestra success',
      (tester) async {
        final auth = AuthState();
        auth.login(UserRole.refugee, userId: 101, userName: 'Refugee');

        // Mock API:
        // 1) assignment => has_assignment true
        // 2) recommendation => JSON completo mínimo para RecommendationResponse.fromJson
        ApiService.client = MockClient((request) async {
          final url = request.url.toString().toLowerCase();

          if (url.contains('assignment')) {
            return http.Response(json.encode({'has_assignment': true}), 200);
          }

          if (url.contains('recommendation')) {
            final payload = {
              // incluyo snake_case + camelCase para cubrir distintos parsers
              'refugee_name': 'Refu',
              'refugeeName': 'Refu',
              'refugee_age': 25,
              'refugeeAge': 25,
              'refugee_nationality': 'Test',
              'refugeeNationality': 'Test',
              'refugee_family_size': 1,
              'refugeeFamilySize': 1,
              'refugee_gender': 'Male',
              'refugeeGender': 'Male',
              'cluster_id': 1,
              'clusterId': 1,
              'cluster_label': 'A',
              'clusterLabel': 'A',
              'vulnerability_level': 'High',
              'vulnerabilityLevel': 'High',
              'total_shelters_analyzed': 10,
              'totalSheltersAnalyzed': 10,
              'ml_model_version': '1.0',
              'mlModelVersion': '1.0',
              'recommendations': [
                {
                  'shelter_id': 1,
                  'shelterId': 1,
                  'shelter_name': 'Shelter One',
                  'shelterName': 'Shelter One',
                  'address': 'Street 1',
                  'compatibility_score': 90.0,
                  'compatibilityScore': 90.0,
                  'priority_score': 80,
                  'priorityScore': 80,
                  'max_capacity': 100,
                  'maxCapacity': 100,
                  'current_occupancy': 50,
                  'currentOccupancy': 50,
                  'available_space': 50,
                  'availableSpace': 50,
                  'occupancy_rate': 0.5,
                  'occupancyRate': 0.5,
                  'has_medical_facilities': true,
                  'hasMedicalFacilities': true,
                  'has_childcare': false,
                  'hasChildcare': false,
                  'has_disability_access': true,
                  'hasDisabilityAccess': true,
                  'explanation': 'Good fit',
                  'matching_reasons': ['Space'],
                  'matchingReasons': ['Space'],
                }
              ],
            };
            return http.Response(json.encode(payload), 200);
          }

          return http.Response(json.encode({}), 200);
        });

        await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
        await tester.pumpAndSettle();

        // Tap en check assignment
        await tester.tap(find.text('Check assignment and choose shelter'));
        await tester.pumpAndSettle();

        // Debería estar en RecommendationSelectionScreen
        expect(find.byType(RecommendationSelectionScreen), findsOneWidget);

        // Volvemos con true (simula selección confirmada)
        Navigator.of(tester.element(find.byType(RecommendationSelectionScreen))).pop(true);
        await tester.pumpAndSettle();

        expect(find.text('You have successfully confirmed your shelter'), findsOneWidget);
      },
    );

    testWidgets('Botón "View or generate my QR" navega a /refugee-self-form-qr', (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee, userId: 10, userName: 'Aiman');

      ApiService.client = MockClient((request) async {
        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('View or generate my QR'));
      await tester.pumpAndSettle();

      expect(find.text('Self QR Screen'), findsOneWidget);
    });

    testWidgets('Botón "What will happen upon arrival" abre BottomSheet con pasos', (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee, userId: 10, userName: 'Aiman');

      ApiService.client = MockClient((request) async {
        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('What will happen upon arrival'));
      await tester.pumpAndSettle();

      expect(find.text('Upon arriving at the shelter'), findsOneWidget);
      expect(find.text('Show your QR or your name.'), findsOneWidget);
      expect(find.text('We will assign you a safe place.'), findsOneWidget);
      expect(find.text('If you need medical attention, say so immediately.'), findsOneWidget);
    });

    testWidgets('Botón "Request help now" abre Dialog y se cierra con Understood', (tester) async {
      final auth = AuthState();
      auth.login(UserRole.refugee, userId: 10, userName: 'Aiman');

      ApiService.client = MockClient((request) async {
        return http.Response(json.encode({}), 200);
      });

      await tester.pumpWidget(wrapWithAuth(auth: auth, child: const RefugeeProfileScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Request help now'));
      await tester.pumpAndSettle();

      expect(find.text('Request urgent help'), findsOneWidget);
      expect(find.textContaining('We can prioritize you'), findsOneWidget);

      await tester.tap(find.text('Understood'));
      await tester.pumpAndSettle();

      expect(find.text('Request urgent help'), findsNothing);
    });
  });
}
