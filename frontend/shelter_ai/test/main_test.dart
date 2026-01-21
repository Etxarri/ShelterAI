import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

// Imports de tu app
import 'package:shelter_ai/main.dart' as app;
import 'package:shelter_ai/main.dart';
import 'package:shelter_ai/services/api_service.dart';

// Imports de todas las pantallas (Asegúrate de que las rutas sean correctas)
import 'package:shelter_ai/screens/welcome_screen.dart';
import 'package:shelter_ai/screens/refugee_landing_screen.dart';
import 'package:shelter_ai/screens/refugee_login_screen.dart';
import 'package:shelter_ai/screens/refugee_register_screen.dart';
import 'package:shelter_ai/screens/login_screen.dart';
import 'package:shelter_ai/screens/register_screen.dart';
import 'package:shelter_ai/screens/worker_dashboard_screen.dart';
import 'package:shelter_ai/screens/refugee_profile_screen.dart';
import 'package:shelter_ai/screens/refugee_list_screen.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';
import 'package:shelter_ai/screens/shelter_list_screen.dart';
import 'package:shelter_ai/screens/refugee_self_form_qr_screen.dart';

void main() {
  
  // Mock Global que responde con éxito genérico para evitar errores de red al navegar
  void setupGlobalMock() {
    final mockClient = MockClient((request) async {
      // Respondemos JSON válido para que ninguna pantalla explote al cargar
      return http.Response('[]', 200);
    });
    ApiService.client = mockClient;
  }

  testWidgets('Main arranca correctamente', (WidgetTester tester) async {
    setupGlobalMock();
    app.main();
    await tester.pumpAndSettle();
    expect(find.byType(ShelterAIApp), findsOneWidget);
  });

  testWidgets('Navegación completa: Cubre todas las rutas de main.dart', (WidgetTester tester) async {
    setupGlobalMock();
    
    // Pantalla gigante para evitar overflows en pantallas largas
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ShelterAIApp());
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(WelcomeScreen));

    // Lista exhaustiva de todas tus rutas
    final routes = [
      '/refugee-landing',
      '/refugee-login',
      '/refugee-register',
      '/login',
      '/register',
      '/worker-dashboard',
      '/refugee-profile',
      '/refugees',
      '/add_refugee',
      '/shelters',
      '/refugee-self-form-qr',
      // '/welcome' ya es la inicial
    ];

    for (final route in routes) {
      // Navegamos
      Navigator.pushNamed(context, route);
      await tester.pumpAndSettle();
      
      // Volvemos atrás para probar la siguiente
      Navigator.pop(context);
      await tester.pumpAndSettle();
    }
  });
}