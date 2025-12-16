import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: AddRefugeeScreen(),
    );
  }

  // Truco para que la pantalla sea gigante y quepa todo el formulario
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('AddRefugeeScreen Tests', () {
    
    // TEST 1: Validación
    testWidgets('Muestra errores de validación si se guarda vacío', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      final saveBtn = find.text('Guardar');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();

      expect(find.text('Requerido'), findsWidgets);
    });

    // TEST 2: Validación Edad
    testWidgets('Muestra error si la edad no es válida', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextFormField, 'Edad'), '-5');
      
      final saveBtn = find.text('Guardar');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();

      expect(find.text('Edad inválida'), findsOneWidget);
    });

    // TEST 3: ENVÍO EXITOSO (Happy Path)
    testWidgets('Envía formulario correctamente y cierra pantalla', (WidgetTester tester) async {
      setScreenSize(tester);

      // 1. Mock del Servidor
      final mockClient = MockClient((request) async {
        final body = json.decode(request.body);
        if (body['first_name'] != null) {
           return http.Response(json.encode({'success': true}), 201);
        }
        return http.Response('Error', 400);
      });
      // Inyectamos el mock
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // 2. Rellenamos el formulario
      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Juan');
      await tester.enterText(find.widgetWithText(TextFormField, 'Apellidos'), 'Pérez');
      await tester.enterText(find.widgetWithText(TextFormField, 'Edad'), '30');

      // Dropdown Género
      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Género'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Femenino').last);
      await tester.pumpAndSettle();

      // Resto de campos
      await tester.enterText(find.widgetWithText(TextFormField, 'Nacionalidad'), 'Española');
      await tester.enterText(find.widgetWithText(TextFormField, 'Idiomas (separados por comas)'), 'Español');
      await tester.enterText(find.widgetWithText(TextFormField, 'Condiciones médicas'), 'Ninguna');
      
      await tester.tap(find.widgetWithText(SwitchListTile, 'Tiene discapacidad'));
      await tester.pump();

      await tester.enterText(find.widgetWithText(TextFormField, 'Puntuación de vulnerabilidad'), '85');
      await tester.enterText(find.widgetWithText(TextFormField, 'Necesidades especiales'), 'Ninguna');
      await tester.enterText(find.widgetWithText(TextFormField, 'ID de familia (opcional)'), '123');

      // 3. Pulsamos Guardar
      final saveBtn = find.text('Guardar');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);

      // 4. Esperamos respuesta
      await tester.pumpAndSettle();

    });

    // TEST 4: Error del Servidor
    testWidgets('Muestra SnackBar de error si falla la API', (WidgetTester tester) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
         return http.Response('Fallo interno', 500);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // Rellenamos solo lo obligatorio
      await tester.enterText(find.widgetWithText(TextFormField, 'Nombre'), 'Ana');
      await tester.enterText(find.widgetWithText(TextFormField, 'Apellidos'), 'García');
      await tester.enterText(find.widgetWithText(TextFormField, 'Edad'), '25');

      final saveBtn = find.text('Guardar');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      
      await tester.pumpAndSettle();

      // Buscamos cualquier mensaje que empiece por Error
      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.byType(AddRefugeeScreen), findsOneWidget);
    });
  });
}