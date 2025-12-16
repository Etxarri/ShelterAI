import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/refugee_list_screen.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';

void main() {
  // Helper para envolver la pantalla en MaterialApp
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: RefugeeListScreen(),
    );
  }

  // Helper para pantalla grande (evita errores de renderizado en listas largas)
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('RefugeeListScreen Tests', () {

    // ----------------------------------------------------------------------
    // TEST 1: ESTADO DE CARGA (CircularProgressIndicator)
    // ----------------------------------------------------------------------
    testWidgets('Muestra indicador de carga mientras espera la API', (WidgetTester tester) async {
      // Mock que tarda un poco en responder (para que nos dé tiempo a ver la carga)
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 500)); 
        return http.Response('[]', 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // 🛑 NO usamos pumpAndSettle aquí, porque queremos ver el "durante", no el "final".
      // Usamos pump(Duration) para avanzar solo un poquito el tiempo.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Ahora sí dejamos que termine para limpiar el test
      await tester.pumpAndSettle();
    });

    // ----------------------------------------------------------------------
    // TEST 2: LISTA VACÍA ("No hay datos")
    // ----------------------------------------------------------------------
    testWidgets('Muestra mensaje cuando no hay refugiados', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200); // Lista vacía
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Esperamos a que termine la carga

      expect(find.text('No hay datos'), findsOneWidget);
      expect(find.byType(RefugeeCard), findsNothing);
    });

    // ----------------------------------------------------------------------
    // TEST 3: CON DATOS (Muestra RefugeeCards)
    // ----------------------------------------------------------------------
    testWidgets('Muestra lista de tarjetas cuando la API devuelve datos', (WidgetTester tester) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        // Devolvemos 2 refugiados simulados
        final mockData = [
          {
            'first_name': 'Juan',
            'last_name': 'Perez',
            'age': 30,
            'nationality': 'Siria',
            'vulnerability_score': 80.5
          },
          {
            'first_name': 'Maria',
            'last_name': 'Gomez',
            'age': 25,
            'nationality': 'Ucrania',
            'vulnerability_score': 60.0
          }
        ];
        return http.Response(json.encode(mockData), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Esperamos a que se pinte todo

      // Verificamos que ya NO sale el loading ni el texto de vacío
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No hay datos'), findsNothing);

      // Verificamos que hay una lista y tarjetas
      expect(find.byType(ListView), findsOneWidget);
      // Debería haber 2 tarjetas RefugeeCard
      expect(find.byType(RefugeeCard), findsNWidgets(2));
    });

  });
}