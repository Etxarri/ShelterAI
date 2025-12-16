import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/home_screen.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }

  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('HomeScreen Tests', () {

    // ----------------------------------------------------------------------
    // TEST 1: ELEMENTOS BÁSICOS DE LA PANTALLA
    // ----------------------------------------------------------------------
    testWidgets('Muestra título y botones principales', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar que el título está presente
      expect(find.text('ShelterAI'), findsOneWidget);
      expect(find.text('Bienvenido a ShelterAI'), findsOneWidget);
      
      // Verificar que los tres botones principales están presentes
      expect(find.text('Añadir refugiado'), findsOneWidget);
      expect(find.text('Refugiados'), findsOneWidget);
      expect(find.text('Refugios'), findsOneWidget);
    });

    // ----------------------------------------------------------------------
    // TEST 2: RESUMEN RÁPIDO CON DATOS
    // ----------------------------------------------------------------------
    testWidgets('Muestra resumen rápido con datos', (WidgetTester tester) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('refugees')) {
          return http.Response(json.encode([
            {
              'first_name': 'Juan',
              'last_name': 'Pérez',
              'age': 30,
              'nationality': 'Siria',
              'vulnerability_score': 80
            },
            {
              'first_name': 'María',
              'last_name': 'García',
              'age': 25,
              'nationality': 'Ucrania',
              'vulnerability_score': 60
            }
          ]), 200);
        } else if (request.url.toString().contains('shelters')) {
          return http.Response(json.encode([
            {
              'name': 'Refugio Central',
              'address': 'Calle Mayor 1',
              'max_capacity': 100,
              'current_occupancy': 50,
              'shelter_type': 'Temporal'
            }
          ]), 200);
        }
        return http.Response('[]', 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificar que se muestra el resumen rápido
      expect(find.text('Resumen rápido'), findsOneWidget);
      expect(find.text('Total refugiados'), findsOneWidget);
      expect(find.text('2 registrados'), findsOneWidget);
      expect(find.text('Refugios disponibles'), findsOneWidget);
      expect(find.text('1 registrados'), findsOneWidget);

      // Verificar que se muestran las vistas rápidas
      expect(find.text('Vistas rápidas'), findsOneWidget);
      expect(find.byType(ShelterCard), findsOneWidget);
      expect(find.byType(RefugeeCard), findsOneWidget);
    });

    // ----------------------------------------------------------------------
    // TEST 3: LISTA VACÍA
    // ----------------------------------------------------------------------
    testWidgets('Maneja correctamente cuando no hay datos', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Los contadores deberían mostrar 0
      expect(find.text('0 registrados'), findsNWidgets(2));
      
      // No deberían aparecer tarjetas en las vistas rápidas
      expect(find.byType(ShelterCard), findsNothing);
      expect(find.byType(RefugeeCard), findsNothing);
    });

    // ----------------------------------------------------------------------
    // TEST 4: NAVEGACIÓN
    // ----------------------------------------------------------------------
    testWidgets('Los botones de navegación funcionan', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      bool refugeesRouteVisited = false;
      bool sheltersRouteVisited = false;

      await tester.pumpWidget(MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/add_refugee': (context) => const Scaffold(body: Text('Add Refugee Screen')),
          '/refugees': (context) {
            refugeesRouteVisited = true;
            return const Scaffold(body: Text('Refugees Screen'));
          },
          '/shelters': (context) {
            sheltersRouteVisited = true;
            return const Scaffold(body: Text('Shelters Screen'));
          },
        },
      ));
      await tester.pumpAndSettle();

      // Test navegación a refugiados
      await tester.tap(find.text('Refugiados'));
      await tester.pumpAndSettle();
      expect(refugeesRouteVisited, true);
      expect(find.text('Refugees Screen'), findsOneWidget);
    });

  });
}
