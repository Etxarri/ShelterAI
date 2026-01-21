import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/main.dart'; // Para acceder a AuthScope

void main() {
  // Helper para envolver la pantalla con el AuthScope necesario
  Widget createWidgetUnderTest() {
    return AuthScope(
      state: AuthState(), // Estado vacío por defecto
      child: const MaterialApp(
        home: AddRefugeeScreen(),
      ),
    );
  }

  // Helper para pantalla grande (evita errores de scroll)
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('AddRefugeeScreen Tests', () {
    
    // JSON de Respuesta Exitosa (Simula lo que devuelve el backend)
    final mockSuccessResponse = {
      "refugee": {
        "id": 1,
        "first_name": "Juan",
        "last_name": "Perez",
        "age": 30,
        "gender": "Male",
        "nationality": "Test",
        "vulnerability_score": 10.0,
        "has_disability": false
      },
      "assignment": {
        "id": 100,
        "shelter_id": 1,
        "shelter_name": "Refugio Seguro",
        "priority_score": 80.0,
        "confidence_percentage": 95.0, // O confidence_score según tu API
        "status": "confirmed",
        "assigned_at": "2023-10-10",
        "explanation": "Coincidencia perfecta",
        "matching_reasons": ["Espacio disponible"],
        "alternative_shelters": []
      }
    };

    // ----------------------------------------------------------------------
    // TEST 1: Validación de campos vacíos
    // ----------------------------------------------------------------------
    testWidgets('Shows validation errors if saved empty', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      // Pulsamos guardar sin rellenar nada
      await tester.tap(find.text('Save'));
      await tester.pump();

      // Deberían salir mensajes de error
      expect(find.text('Required'), findsWidgets);
    });

    // ----------------------------------------------------------------------
    // TEST 2: Validación de edad
    // ----------------------------------------------------------------------
    testWidgets('Shows error if age is invalid', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      // Ponemos una edad negativa
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '-5');
      
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Invalid age'), findsOneWidget);
    });

    // ----------------------------------------------------------------------
    // TEST 3: Envío Exitoso y Diálogo
    // ----------------------------------------------------------------------
    testWidgets('Submits form correctly and shows success dialog', (WidgetTester tester) async {
      setScreenSize(tester);

      // Mock exitoso
      ApiService.client = MockClient((request) async {
        return http.Response(json.encode(mockSuccessResponse), 200);
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Rellenamos el formulario
      await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Juan');
      await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'Perez');
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '30');
      
      // Scroll hasta el botón
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pump();

      // Guardar
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(); // Esperar animación y diálogo

      // Verificamos que sale el diálogo con la info del refugio asignado
      expect(find.text('Refugee Registered'), findsOneWidget);
      expect(find.text('Refugio Seguro'), findsOneWidget); // Nombre del refugio en el mock
    });

    // ----------------------------------------------------------------------
    // TEST 4: Error de API
    // ----------------------------------------------------------------------
    testWidgets('Shows error SnackBar if API fails', (WidgetTester tester) async {
      setScreenSize(tester);

      // Mock de error 500
      ApiService.client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Rellenamos datos mínimos
      await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Ana');
      await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'Gomez');
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '25');

      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pump();

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verificar SnackBar de error
      expect(find.textContaining('Error saving'), findsOneWidget);
    });

    // ----------------------------------------------------------------------
    // TEST 5: Cerrar Diálogo
    // ----------------------------------------------------------------------
    testWidgets('Close button dismisses dialog', (WidgetTester tester) async {
      setScreenSize(tester);

      ApiService.client = MockClient((request) async {
        return http.Response(json.encode(mockSuccessResponse), 200);
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Rellenar y guardar
      await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Test');
      await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'User');
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '20');
      
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pump();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verificar que el diálogo está abierto
      expect(find.text('Refugee Registered'), findsOneWidget);

      // Pulsar "Close"
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verificar que el diálogo se cerró
      expect(find.text('Refugee Registered'), findsNothing);
    });

  });
}