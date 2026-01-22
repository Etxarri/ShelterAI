import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/main.dart';

// Screens
import 'package:shelter_ai/screens/refugee_self_form_qr_screen.dart';
import 'package:shelter_ai/screens/recommendation_selection_screen.dart';

// Models
import 'package:shelter_ai/models/recommendation_response.dart';
import 'package:shelter_ai/models/recommendation.dart';

void main() {
  // ✅ Pantalla grande para que no queden botones off-screen
  void setBigScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  Widget wrapWithAuth(Widget child, {AuthState? auth}) {
    final state = auth ?? AuthState();
    if (!state.isAuthenticated) {
      state.login(UserRole.refugee, userId: 1, userName: "Refugee");
    }

    return AuthScope(
      state: state,
      child: MaterialApp(home: child),
    );
  }

  group('Refugee Specific Features', () {
    // -------------------------------------------------------------------------
    // 1) REFUGEE SELF FORM QR
    // -------------------------------------------------------------------------
    testWidgets(
      'RefugeeSelfFormQrScreen: Rellena formulario y genera QR',
      (WidgetTester tester) async {
        setBigScreen(tester);

        await tester.pumpWidget(wrapWithAuth(const RefugeeSelfFormQrScreen()));
        await tester.pumpAndSettle();

        final generateBtn = find.text('Generate and save my QR');

        // Tap vacío -> validación
        await tester.ensureVisible(generateBtn);
        await tester.tap(generateBtn);
        await tester.pumpAndSettle();
        expect(find.text('Required'), findsWidgets);

        // Rellenar
        await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Self');
        await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'Refugee');
        await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '30');

        // Generar QR
        await tester.ensureVisible(generateBtn);
        await tester.tap(generateBtn);
        await tester.pumpAndSettle();

        expect(find.text('Your QR Code'), findsOneWidget);

        // Cerrar diálogo
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();
        expect(find.text('Your QR Code'), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // 2) RECOMMENDATION SELECTION SCREEN
    // -------------------------------------------------------------------------
    testWidgets(
      'RecommendationSelectionScreen: Muestra lista y selecciona',
      (WidgetTester tester) async {
        setBigScreen(tester);

        // Mock API éxito
        ApiService.client = MockClient((request) async {
          return http.Response(json.encode({"success": true}), 200);
        });

        final response = RecommendationResponse(
          refugeeName: "Refu",
          clusterId: 1,
          clusterLabel: "A",
          vulnerabilityLevel: "High",
          message: "Refugios encontrados",
          recommendations: [
            Recommendation(
              shelterId: 101,
              shelterName: "Shelter One",
              address: "Street 1",
              compatibilityScore: 90.0,
              availableSpace: 50,
              hasMedicalFacilities: true,
              hasDisabilityAccess: true,
              explanation: "Good fit",
              matchingReasons: ["Space available"],
            ),
          ],
        );

        // ✅ Home dummy con botón para push -> así el pop(true) tiene ruta anterior segura
        final dummyHome = Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(_dummyContext!).push(
                  MaterialPageRoute(
                    builder: (_) => RecommendationSelectionScreen(
                      recommendationResponse: response,
                      refugeeId: 1,
                    ),
                  ),
                );
              },
              child: const Text('OPEN'),
            ),
          ),
        );

        // Truco simple para tener un BuildContext válido para Navigator.of(context)
        _dummyContext = null;

        await tester.pumpWidget(
          AuthScope(
            state: AuthState()..login(UserRole.refugee, userId: 1, userName: "Refugee"),
            child: MaterialApp(
              home: Builder(
                builder: (context) {
                  _dummyContext = context;
                  return dummyHome;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Abrir pantalla
        await tester.tap(find.text('OPEN'));
        await tester.pumpAndSettle();

        // Renderizado
        expect(find.text('Shelter One'), findsOneWidget);

        // Tap en el shelter
        await tester.tap(find.text('Shelter One'));
        await tester.pump();

        // Si hay confirmación, aceptarla
        final confirmCandidates = <String>[
          'Confirm',
          'Assign',
          'Yes',
          'OK',
          'Ok',
          'Understood',
        ];

        for (final label in confirmCandidates) {
          final f = find.text(label);
          if (f.evaluate().isNotEmpty) {
            await tester.tap(f.first);
            await tester.pump();
            break;
          }
        }

        // ✅ Capturar SnackBar antes del delayed(1s) + pop
        await tester.pump(const Duration(milliseconds: 100));

        // Si el texto exacto cambia, al menos que exista SnackBar
        expect(find.byType(SnackBar), findsOneWidget);

        // ✅ Consumir el Timer de 1s para que no queden timers pendientes
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // Tras pop, volvemos al dummy home
        expect(find.text('OPEN'), findsOneWidget);
      },
    );
  });
}

// Context global solo para empujar route desde dummyHome
BuildContext? _dummyContext;
