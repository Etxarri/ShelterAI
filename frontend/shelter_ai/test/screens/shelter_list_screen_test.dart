import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// 👇 IMPORTS: Asegúrate de que coinciden con los de tu pantalla real
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/shelter_list_screen.dart'; // Ajusta si el nombre del archivo es distinto
import 'package:shelter_ai/widgets/shelter_card.dart';

void main() {
  
  // Helper básico
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ShelterListScreen(),
    );
  }

  // Helper para pantalla grande (evita overflow en listas)
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('ShelterListScreen Tests', () {

    // ----------------------------------------------------------------------
    // TEST 1: ESTADO DE CARGA (Loading)
    // ----------------------------------------------------------------------
    testWidgets('Muestra loading mientras carga', (WidgetTester tester) async {
      // Mock que tarda un poco
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 100)); 
        return http.Response('[]', 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // Solo avanzamos un frame, no esperamos a que termine (pump, NO pumpAndSettle)
      await tester.pump(); 

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Limpiamos terminando la animación
      await tester.pumpAndSettle();
    });

    // ----------------------------------------------------------------------
    // TEST 2: LISTA VACÍA (Empty State)
    // ----------------------------------------------------------------------
    testWidgets('Muestra "No hay datos" si la lista está vacía', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200); // Array vacío
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Esperamos a que termine todo

      expect(find.text('No hay datos'), findsOneWidget);
      expect(find.byType(ShelterCard), findsNothing);
    });

    // ----------------------------------------------------------------------
    // TEST 3: CON DATOS (Happy Path)
    // ----------------------------------------------------------------------
    testWidgets('Muestra lista de tarjetas de refugios', (WidgetTester tester) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        // Datos simulados de refugios
        final mockData = [
          {
            'name': 'Refugio Central',
            'address': 'Calle Mayor 1',
            'capacity': 100,
            'occupancy': 50,
            'phone': '555-1234'
          },
          {
            'name': 'Albergue Norte',
            'address': 'Av. Libertad 20',
            'capacity': 60,
            'occupancy': 10,
            'phone': '555-5678'
          }
        ];
        return http.Response(json.encode(mockData), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verificamos que NO sale loading ni vacío
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No hay datos'), findsNothing);

      // Verificamos que salen las tarjetas
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ShelterCard), findsNWidgets(2)); // Esperamos 2 tarjetas
      
      // Opcional: Verificar que sale el nombre de un refugio
      expect(find.text('Refugio Central'), findsOneWidget);
    });

  });
}