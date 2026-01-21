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
