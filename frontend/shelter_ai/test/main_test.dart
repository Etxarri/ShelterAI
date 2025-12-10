import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// 👇 TRUCO DE MAESTRO:
// Importamos main.dart con un alias 'app' para poder llamar a su función main()
import 'package:shelter_ai/main.dart' as app;
import 'package:shelter_ai/main.dart'; // Import normal para usar la clase ShelterAIApp

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/home_screen.dart';
import 'package:shelter_ai/screens/refugee_list_screen.dart';
import 'package:shelter_ai/screens/shelter_list_screen.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';

void main() {
  
  // Mock Global para evitar errores de red en cualquier test
  void setupGlobalMock() {
    final mockClient = MockClient((request) async {
      return http.Response('[]', 200);
    });
    ApiService.client = mockClient;
  }

  // ----------------------------------------------------------
  // 🟢 TEST NUEVO: Cubrir la función main() (Líneas 7-8)
  // ----------------------------------------------------------
  testWidgets('La función main() arranca la app correctamente', (WidgetTester tester) async {
    setupGlobalMock();

    // Al llamar a app.main(), se ejecuta "runApp(const ShelterAIApp());"
    // Esto marca como VERDES las líneas que te faltaban.
    app.main();
    
    // Esperamos a que la app arranque y se pinte
    await tester.pumpAndSettle();

    // Verificamos que la app está en pantalla
    expect(find.byType(ShelterAIApp), findsOneWidget);
  });

  // ----------------------------------------------------------
  // RESTO DE TESTS (Navegación y Rutas)
  // ----------------------------------------------------------
  testWidgets('Navegación: Cubre todas las rutas definidas en main.dart', (WidgetTester tester) async {
    setupGlobalMock();
    
    // Pantalla grande para evitar errores de renderizado
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.resetPhysicalSize);

    // Aquí usamos la forma estándar para testear navegación
    await tester.pumpWidget(const ShelterAIApp());
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(HomeScreen));

    // RUTA 1: /refugees
    Navigator.pushNamed(context, '/refugees');
    await tester.pumpAndSettle();
    expect(find.byType(RefugeeListScreen), findsOneWidget);
    Navigator.pop(context);
    await tester.pumpAndSettle();

    // RUTA 2: /shelters
    Navigator.pushNamed(context, '/shelters');
    await tester.pumpAndSettle();
    expect(find.byType(ShelterListScreen), findsOneWidget);
    Navigator.pop(context);
    await tester.pumpAndSettle();

    // RUTA 3: /add_refugee
    Navigator.pushNamed(context, '/add_refugee');
    await tester.pumpAndSettle();
    expect(find.byType(AddRefugeeScreen), findsOneWidget);
    Navigator.pop(context);
    await tester.pumpAndSettle();
  });
}