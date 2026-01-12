import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:shelter_ai/main.dart' as app;
import 'package:shelter_ai/main.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/home_screen.dart';
import 'package:shelter_ai/screens/refugee_list_screen.dart';
import 'package:shelter_ai/screens/shelter_list_screen.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';

void main() {
  
  // Mock Global para evitar errores de red en cualquier test
  void setupGlobalMock() {
    final mockClient = MockClient((request) async {
      return http.Response(json.encode([]), 200);
    });
    ApiService.client = mockClient;
  }

  // ----------------------------------------------------------
  // TEST 1: Cubrir la función main()
  // ----------------------------------------------------------
  testWidgets('La función main() arranca la app correctamente', (WidgetTester tester) async {
    setupGlobalMock();

    app.main();
    
    await tester.pumpAndSettle();

    expect(find.byType(ShelterAIApp), findsOneWidget);
  });

  // ----------------------------------------------------------
  // TEST 2: Navegación y Rutas
  // ----------------------------------------------------------
  testWidgets('Navegación: Cubre todas las rutas definidas en main.dart', (WidgetTester tester) async {
    setupGlobalMock();
    
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.resetPhysicalSize);

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