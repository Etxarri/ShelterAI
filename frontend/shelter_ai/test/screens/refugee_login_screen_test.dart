import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/refugee_login_screen.dart';
import 'package:shelter_ai/services/api_service.dart';

void main() {
  late http.Client oldClient;

  setUp(() {
    oldClient = ApiService.client;
  });

  tearDown(() {
    ApiService.client = oldClient;
  });

  Widget _wrapWithAuth(AuthState state) {
    return MaterialApp(
      home: AuthScope(
        state: state,
        child: const RefugeeLoginScreen(),
      ),
      routes: {
        '/refugee-landing': (_) =>
            const Scaffold(body: Center(child: Text('LANDING'))),
        '/refugee-register': (_) =>
            const Scaffold(body: Center(child: Text('REGISTER'))),
        '/worker-dashboard': (_) =>
            const Scaffold(body: Center(child: Text('WORKER_DASH'))),
        '/refugee-profile': (_) =>
            const Scaffold(body: Center(child: Text('REFUGEE_PROFILE'))),
      },
    );
  }

  Finder _byLabel(String label) {
    // En tu screen usas TextField con labelText (InputDecoration)
    return find.byWidgetPredicate((w) {
      if (w is! TextField) return false;
      final dec = w.decoration;
      return dec?.labelText == label;
    });
  }

  Future<void> _enterCredentials(
    WidgetTester tester, {
    required String identifier,
    required String password,
  }) async {
    await tester.enterText(
      _byLabel('Email, phone or username'),
      identifier,
    );
    await tester.enterText(
      _byLabel('Password'),
      password,
    );
    await tester.pump();
  }

  group('RefugeeLoginScreen', () {
    testWidgets('Renderiza textos y botones principales', (tester) async {
      final auth = AuthState();
      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Refugee Access'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text("Don't have an account? Register"), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('Campos vacios -> SnackBar required', (tester) async {
      final auth = AuthState();
      ApiService.client = MockClient((request) async {
        return http.Response('should not be called', 500);
      });

      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign in'));
      await tester.pump(); // muestra SnackBar

      expect(
        find.text('Email, phone or username and password required'),
        findsOneWidget,
      );
    });

    testWidgets('Loading: muestra spinner, texto Signing in... y deshabilita inputs', (tester) async {
      final auth = AuthState();

      ApiService.client = MockClient((request) async {
        // tarda un poco para quedarnos en loading
        await Future.delayed(const Duration(milliseconds: 300));
        return http.Response(
          jsonEncode({
            'success': true,
            'user_id': 1,
            'first_name': 'A',
            'last_name': 'B',
            'role': 'refugee',
            'token': 't',
          }),
          200,
        );
      });

      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      await _enterCredentials(tester, identifier: 'user', password: 'pass');

      await tester.tap(find.text('Sign in'));
      await tester.pump(); // entra en loading

      // spinner dentro del boton
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing in...'), findsOneWidget);

      // inputs deshabilitados mientras carga
      final idField = tester.widget<TextField>(_byLabel('Email, phone or username'));
      final pwField = tester.widget<TextField>(_byLabel('Password'));
      expect(idField.enabled, isFalse);
      expect(pwField.enabled, isFalse);

      // deja que termine para no dejar test colgado
      await tester.pumpAndSettle();
    });

    testWidgets('Login OK refugee -> navega /refugee-profile', (tester) async {
      final auth = AuthState();

      ApiService.client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), contains('/api/login'));

        return http.Response(
          jsonEncode({
            'success': true,
            'user_id': 10,
            'first_name': 'Juan',
            'last_name': 'Perez',
            'role': 'refugee',
            'token': 'tok',
          }),
          200,
        );
      });

      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      await _enterCredentials(tester, identifier: 'juan', password: 'pw');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('REFUGEE_PROFILE'), findsOneWidget);

      // check que el estado se actualizó (campos típicos)
      expect(auth.userId, 10);
      expect(auth.userName, 'Juan Perez');
    });

    testWidgets('Login OK worker -> navega /worker-dashboard', (tester) async {
      final auth = AuthState();

      ApiService.client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'user_id': 99,
            'first_name': 'Worker',
            'last_name': 'One',
            'role': 'worker',
            'token': 'tokW',
          }),
          200,
        );
      });

      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      await _enterCredentials(tester, identifier: 'w', password: 'pw');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('WORKER_DASH'), findsOneWidget);
      expect(auth.userId, 99);
      expect(auth.userName, 'Worker One');
    });

    testWidgets('Login KO -> SnackBar Error:', (tester) async {
      final auth = AuthState();

      ApiService.client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      await _enterCredentials(tester, identifier: 'bad', password: 'bad');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('Boton Register -> navega /refugee-register', (tester) async {
      final auth = AuthState();
      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      expect(find.text('REGISTER'), findsOneWidget);
    });

    testWidgets('Boton Back (abajo) -> navega /refugee-landing', (tester) async {
      final auth = AuthState();
      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(find.text('LANDING'), findsOneWidget);
    });

    testWidgets('Flecha atras AppBar -> navega /refugee-landing', (tester) async {
      final auth = AuthState();
      await tester.pumpWidget(_wrapWithAuth(auth));
      await tester.pumpAndSettle();

      // leading IconButton
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('LANDING'), findsOneWidget);
    });
  });
}
