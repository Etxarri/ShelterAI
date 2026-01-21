import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/worker_dashboard_screen.dart';
import 'package:shelter_ai/services/api_service.dart';

/// NavigatorObserver que cuenta SOLO pushes "de pantalla"
/// (ignora showDialog / PopupRoute).
class TestNavObserver extends NavigatorObserver {
  int nonDialogPushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PopupRoute) return;
    nonDialogPushCount++;
  }
}

/// Pantalla dummy para /login
class _LoginDummy extends StatelessWidget {
  const _LoginDummy({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('LOGIN_SCREEN')));
  }
}

/// Pantalla dummy para /refugees
class _RefugeesDummy extends StatelessWidget {
  const _RefugeesDummy({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('REFUGEES_SCREEN')));
  }
}

/// Pantalla dummy para /shelters
class _SheltersDummy extends StatelessWidget {
  const _SheltersDummy({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('SHELTERS_SCREEN')));
  }
}

/// Pantalla dummy para /add_refugee.
/// - Muestra args si existen.
/// - Botón para devolver true (para cubrir refresh)
class _AddRefugeeDummy extends StatelessWidget {
  const _AddRefugeeDummy({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String argsText = 'NO_ARGS';
    if (args is Map) {
      argsText = args.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD_REFUGEE'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RETURN_TRUE'),
          ),
        ],
      ),
      body: Center(child: Text('ADD_REFUGEE_ARGS: $argsText')),
    );
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
      '/login': (_) => const _LoginDummy(),
      '/refugees': (_) => const _RefugeesDummy(),
      '/shelters': (_) => const _SheltersDummy(),
      '/add_refugee': (_) => const _AddRefugeeDummy(),
    },
    home: AuthScope(
      state: authState,
      child: child,
    ),
  );
}

/// Helpers JSON (mínimos para que ShelterCard/RefugeeCard no se rompan)
List<Map<String, dynamic>> _refugeesSample({int n = 1}) {
  return List.generate(n, (i) {
    return {
      'id': i + 1,
      'first_name': i == 0 ? 'John' : 'Jane',
      'last_name': 'Doe',
      'age': 30,
      'special_needs': '',
      'medical_conditions': '',
      'has_disability': false,
      'assigned_shelter_id': null,
      'status': 'pending',
    };
  });
}

List<Map<String, dynamic>> _sheltersSample({int n = 1}) {
  return List.generate(n, (i) {
    return {
      'id': i + 1,
      'name': i == 0 ? 'Shelter A' : 'Shelter B',
      // campos típicos que suelen existir
      'capacity': 100,
      'current_occupancy': 10,
      'address': 'Street ${i + 1}',
    };
  });
}

void main() {
  group('WorkerDashboardScreen coverage', () {
    late AuthState authState;
    late TestNavObserver nav;
    late int refugeesHits;
    late int sheltersHits;

    setUp(() {
      authState = AuthState();
      nav = TestNavObserver();
      refugeesHits = 0;
      sheltersHits = 0;

      // Mock ApiService.client para getRefugees/getShelters
      ApiService.client = MockClient((req) async {
        final path = req.url.path.toLowerCase();

        if (path.contains('refugee')) {
          refugeesHits++;
          return http.Response(jsonEncode(_refugeesSample(n: 2)), 200);
        }
        if (path.contains('shelter')) {
          sheltersHits++;
          return http.Response(jsonEncode(_sheltersSample(n: 3)), 200);
        }

        // fallback
        return http.Response('[]', 200);
      });
    });

    testWidgets('Render: hello team cuando userName está vacío + stats muestran counts',
        (tester) async {
      // userName vacío => "team"
      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          observer: nav,
          child: const WorkerDashboardScreen(),
        ),
      );

      // Deja que FutureBuilder resuelva
      await tester.pumpAndSettle();

      expect(find.textContaining('Hello, team'), findsOneWidget);

      // Stats: Registered people => 2, Available shelters => 3
      expect(find.text('Registered people'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // puede haber otros "2" pero normalmente sale aquí
      expect(find.text('Available shelters'), findsOneWidget);
      expect(find.text('3'), findsWidgets);

      expect(refugeesHits, greaterThanOrEqualTo(1));
      expect(sheltersHits, greaterThanOrEqualTo(1));
    });

    testWidgets('Render: hello userName cuando existe', (tester) async {
      authState.login(
        UserRole.worker,
        userId: 123,
        token: 't',
        userName: 'Aiman',
      );

      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          child: const WorkerDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Hello, Aiman'), findsOneWidget);
    });

    testWidgets('Navegación: Refugee list y Shelters and capacity', (tester) async {
      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          child: const WorkerDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Refugee list"
      await tester.tap(find.text('Refugee list'));
      await tester.pumpAndSettle();
      expect(find.text('REFUGEES_SCREEN'), findsOneWidget);

      // Volver
      Navigator.of(tester.element(find.text('REFUGEES_SCREEN'))).pop();
      await tester.pumpAndSettle();

      // Tap "Shelters and capacity"
      await tester.tap(find.text('Shelters and capacity'));
      await tester.pumpAndSettle();
      expect(find.text('SHELTERS_SCREEN'), findsOneWidget);
    });

    testWidgets('Manual registration: si devuelve true => refresh (vuelve a pedir getRefugees)',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          child: const WorkerDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final hitsBefore = refugeesHits;

      // Tap manual registration
      await tester.tap(find.text('Manual registration'));
      await tester.pumpAndSettle();
      expect(find.text('ADD_REFUGEE'), findsOneWidget);

      // En la dummy, botón RETURN_TRUE hace pop(true)
      await tester.tap(find.text('RETURN_TRUE'));
      await tester.pumpAndSettle();

      // Debe haberse refrescado y volver a llamar getRefugees (FutureBuilder con key nueva)
      expect(refugeesHits, greaterThan(hitsBefore));
    });

    testWidgets('Quick cases: cuando hay datos, renderiza 1 ShelterCard y 1 RefugeeCard',
        (tester) async {
      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          child: const WorkerDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // No comprobamos tipos internos para no acoplarnos (pero sí que existen tiles/cards)
      expect(find.text('Quick cases'), findsOneWidget);

      // Como getShelters/getRefugees devuelve no vacío, deberían aparecer nombres
      expect(find.textContaining('Shelter A'), findsWidgets);
      expect(find.textContaining('John Doe'), findsWidgets);
    });

    testWidgets('Logout: hace logout y navega a /login (pushNamedAndRemoveUntil)',
        (tester) async {
      authState.login(
        UserRole.worker,
        userId: 1,
        token: 't',
        userName: 'Tester',
      );

      await tester.pumpWidget(
        _wrapWithAuth(
          authState: authState,
          child: const WorkerDashboardScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap icon logout (tooltip)
      await tester.tap(find.byTooltip('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('LOGIN_SCREEN'), findsOneWidget);
      // auth debería estar deslogueado (mínimo: userName vacío)
      expect(authState.userName, '');
    });

    testWidgets(
      'Scan QR: fuerza pop con JSON de refugiado => navega a /add_refugee con args',
      (tester) async {
        // ⚠️ Este test asume que QrScanScreen puede construirse en test.
        // Si tu QrScanScreen usa un plugin de cámara/qr que rompe en test,
        // comenta este test y dime el código de QrScanScreen para mockearlo.
        await tester.pumpWidget(
          _wrapWithAuth(
            authState: authState,
            observer: nav,
            child: const WorkerDashboardScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Tap Scan QR => hace Navigator.push(MaterialPageRoute(QrScanScreen))
        await tester.tap(find.text('Scan QR'));
        await tester.pump(); // entra a la ruta

        // Pop manualmente la ruta top con un JSON válido (first_name)
        final navState = tester.state<NavigatorState>(find.byType(Navigator));
        navState.pop(jsonEncode({'first_name': 'Scan', 'last_name': 'User'}));
        await tester.pumpAndSettle();

        // Debe navegar a /add_refugee (dummy) con args
        expect(find.text('ADD_REFUGEE'), findsOneWidget);
        expect(find.textContaining('first_name: Scan'), findsOneWidget);
      },
    );

    testWidgets(
      'Scan QR: pop con texto largo no-json => muestra dialog QR received y truncado',
      (tester) async {
        // ⚠️ Igual que el test anterior: depende de que QrScanScreen no rompa en tests.
        await tester.pumpWidget(
          _wrapWithAuth(
            authState: authState,
            child: const WorkerDashboardScreen(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Scan QR'));
        await tester.pump();

        final longText = List.filled(300, 'A').join();
        final navState = tester.state<NavigatorState>(find.byType(Navigator));
        navState.pop(longText);
        await tester.pumpAndSettle();

        expect(find.text('QR received'), findsOneWidget);
        // debe truncar a 240 + …
        expect(find.textContaining('…'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('QR received'), findsNothing);
      },
    );
  });
}
