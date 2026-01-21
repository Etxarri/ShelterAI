import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/login_screen.dart';
import 'package:shelter_ai/services/api_service.dart';

/// NavigatorObserver que cuenta pushes no-dialog
class TestNavObserver extends NavigatorObserver {
  int pushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PopupRoute) return;
    pushCount++;
  }

  int replaceCount = 0;
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PopupRoute) return;
    replaceCount++;
  }
}

class _DummyScreen extends StatelessWidget {
  final String label;
  const _DummyScreen(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(label)));
  }
}

Widget _wrapWithAuth({
  required AuthState authState,
  required Widget child,
  NavigatorObserver? observer,
}) {
  return MaterialApp(
    navigatorObservers: observer != null ? [observer] : const [],
    routes: {
      '/worker-dashboard': (_) => const _DummyScreen('WORKER_DASHBOARD'),
      '/refugee-profile': (_) => const _DummyScreen('REFUGEE_PROFILE'),
      '/register': (_) => const _DummyScreen('REGISTER_SCREEN'),
      '/welcome': (_) => const _DummyScreen('WELCOME_SCREEN'),
    },
    home: AuthScope(
      state: authState,
      child: child,
    ),
  );
}

Finder _tfByLabel(String label) {
  return find.byWidgetPredicate((w) {
    return w is TextField && w.decoration?.labelText == label;
  });
}

void main() {
  late AuthState authState;
  late TestNavObserver nav; 
  setUp(() {
    authState = AuthState();
    nav = TestNavObserver();
  });
  group('LoginScreen', () {
    

    

    testWidgets('Campos vacíos => CustomSnackBar warning (texto aparece)',
        (tester) async {
      // No se usa HTTP porque corta antes
      ApiService.client = MockClient((_) async => http.Response('{}', 500));

      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          child: const LoginScreen(),
        ),
      );

      await tester.tap(find.text('Sign in'));
      await tester.pump(); // muestra snackbar

      // El texto exacto que mandas a SnackBar
      expect(
        find.text('Email, phone or username and password required'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Login OK worker (name con espacio) => login guarda first/last y navega worker-dashboard',
        (tester) async {
      // Mock login endpoint -> worker
      ApiService.client = MockClient((req) async {
        // AuthService.login pega a /api/login
        if (req.url.path.contains('/api/login')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'user_id': 7,
              'first_name': 'John',
              'last_name': 'Smith',
              'role': 'worker',
              'token': 'token123',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 404);
      });

      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          observer: nav,
          child: const LoginScreen(),
        ),
      );

      // Rellenar campos
      await tester.enterText(
        _tfByLabel('Email, phone or username'),
        'john',
      );
      await tester.enterText(
        _tfByLabel('Password'),
        'pass',
      );

      await tester.tap(find.text('Sign in'));
      await tester.pump(); // entra loading

      // Loading visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Signing in...'), findsOneWidget);

      await tester.pumpAndSettle();

      // Navegación
      expect(find.text('WORKER_DASHBOARD'), findsOneWidget);

      // Estado auth cubierto: userName, firstName, lastName
      expect(authState.userName, 'John Smith');
      expect(authState.firstName, 'John');
      expect(authState.lastName, 'Smith');
      expect(authState.token, 'token123');
      expect(authState.userId, 7);
    });

    testWidgets(
        'Login OK refugee (name sin espacio) => login guarda firstName=name y navega refugee-profile',
        (tester) async {
      ApiService.client = MockClient((req) async {
        if (req.url.path.contains('/api/login')) {
          return http.Response(
            jsonEncode({
              'success': true,
              'user_id': 12,
              'username': 'Aiman',
              'role': 'refugee',
              'token': 'tokR',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{}', 404);
      });

      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          child: const LoginScreen(),
        ),
      );

      await tester.enterText(
        _tfByLabel('Email, phone or username'),
        'aim',
      );
      await tester.enterText(
        _tfByLabel('Password'),
        '123',
      );

      await tester.tap(find.text('Sign in'));
      await tester.pump(); // loading
      expect(find.text('Signing in...'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('REFUGEE_PROFILE'), findsOneWidget);

      // response.name en LoginResponse usa username si no hay first/last
      expect(authState.userName, 'Aiman');
      expect(authState.firstName, 'Aiman');
      expect(authState.lastName, ''); // no había apellido
      expect(authState.userId, 12);
      expect(authState.token, 'tokR');
    });

    
    
  });
}
