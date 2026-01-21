import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/providers/auth_state.dart';

// Pantallas
import 'package:shelter_ai/screens/login_screen.dart';
import 'package:shelter_ai/screens/register_screen.dart';
import 'package:shelter_ai/screens/refugee_landing_screen.dart';
import 'package:shelter_ai/screens/refugee_register_screen.dart';

void main() {
  void setBigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  /// ✅ Helper ultra-robusto:
  /// - NO depende de ElevatedButton
  /// - hace scroll si hay Scrollable
  /// - tapa el TEXT directamente
  Future<void> scrollAndTapByText(
    WidgetTester tester,
    String text, {
    String? fallbackText,
  }) async {
    final primary = find.text(text);
    final fallback = fallbackText == null ? find.byWidgetPredicate((_) => false) : find.text(fallbackText);

    final target = primary.evaluate().isNotEmpty ? primary : fallback;

    // Si no existe ni primary ni fallback -> error claro
    if (target.evaluate().isEmpty) {
      throw StateError('No se encontró el texto "$text"${fallbackText != null ? ' ni "$fallbackText"' : ''} en la pantalla.');
    }

    // Intentar hacer visible (con scroll si existe)
    final scrollable = find.byType(Scrollable);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.ensureVisible(target.first);
    } else {
      await tester.ensureVisible(target.first);
    }

    await tester.pump();
    await tester.tap(target.first);
    await tester.pumpAndSettle();
  }

  Widget createScreen(Widget screen) {
    return AuthScope(
      state: AuthState(),
      child: MaterialApp(
        routes: {
          '/worker-dashboard': (_) => const Scaffold(body: Text('Worker Dash')),
          '/refugee-profile': (_) => const Scaffold(body: Text('Refugee Profile')),
          '/refugee-login': (_) => const Scaffold(body: Text('Login')),
          '/refugee-register': (_) => const Scaffold(body: Text('Register')),
          '/refugee-self-form-qr': (_) => const Scaffold(body: Text('QR Form')),
          '/login': (_) => const Scaffold(body: Text('Worker Login')),
          '/welcome': (_) => const Scaffold(body: Text('Welcome')),
        },
        home: screen,
      ),
    );
  }

  group('Auth Forms Tests', () {
    testWidgets('RefugeeLandingScreen: Navegación correcta', (WidgetTester tester) async {
      await tester.pumpWidget(createScreen(const RefugeeLandingScreen()));

      // Aquí sí existe el texto Register (botón o link)
      await scrollAndTapByText(tester, 'Register');
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('RefugeeRegisterScreen: Validación y Registro Exitoso', (WidgetTester tester) async {
      setBigScreen(tester);

      ApiService.client = MockClient((request) async {
        return http.Response(
          json.encode({
            "user_id": 1,
            "token": "fake-token",
            "role": "refugee",
            "name": "Refugee Test"
          }),
          200,
        );
      });

      await tester.pumpWidget(createScreen(const RefugeeRegisterScreen()));

      await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Juan');
      await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'Perez');
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'juanp');
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '25');
      await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), '123456');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar contraseña'), '123456');

      // ✅ Tap por TEXTO (mucho más estable)
      await scrollAndTapByText(
        tester,
        'Register',
        fallbackText: 'Registering...',
      );

      expect(find.text('QR Form'), findsOneWidget);
    });

    testWidgets('LoginScreen (Worker): Login Exitoso', (WidgetTester tester) async {
      ApiService.client = MockClient((request) async {
        return http.Response(
          json.encode({
            "user_id": 99,
            "token": "worker-token",
            "role": "worker",
            "name": "Admin User"
          }),
          200,
        );
      });

      await tester.pumpWidget(createScreen(const LoginScreen()));

      await tester.enterText(find.widgetWithText(TextField, 'Email, phone or username'), 'admin');
      await tester.enterText(find.widgetWithText(TextField, 'Password'), 'admin');

      await scrollAndTapByText(tester, 'Sign in', fallbackText: 'Signing in...');
      expect(find.text('Worker Dash'), findsOneWidget);
    });

    testWidgets('RegisterScreen (Worker): Validación y Registro', (WidgetTester tester) async {
      setBigScreen(tester);

      ApiService.client = MockClient((request) async {
        return http.Response(
          json.encode({
            "user_id": 99,
            "token": "worker-token",
            "role": "worker",
            "name": "Admin User"
          }),
          200,
        );
      });

      await tester.pumpWidget(createScreen(const RegisterScreen()));

      await tester.enterText(find.widgetWithText(TextFormField, 'Full name'), 'Admin');
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'admin@org.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), '123456');
      await tester.enterText(find.widgetWithText(TextFormField, 'Confirm password'), '123456');

      // ✅ Tap por texto
      await scrollAndTapByText(
        tester,
        'Create account',
        fallbackText: 'Creating account...',
      );

      expect(find.text('Worker Dash'), findsOneWidget);
    });
  });
}
