import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/refugee_list_screen.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';

void main() {
  // Helper to wrap the screen in MaterialApp
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: RefugeeListScreen(),
    );
  }

  // Helper for large screen (avoids rendering errors in long lists)
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('RefugeeListScreen Tests', () {
    // ----------------------------------------------------------------------
    // TEST 1: LOADING STATE
    // ----------------------------------------------------------------------
    testWidgets('Shows loading indicator while waiting for API', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 500));
        return http.Response('[]', 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // Queremos ver el estado "loading"
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Dejar que termine
      await tester.pumpAndSettle();
    });
    // ----------------------------------------------------------------------
    // TEST 3: WITH DATA
    // ----------------------------------------------------------------------
    testWidgets('Shows list of cards when API returns data', (WidgetTester tester) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        // Return 2 simulated refugees
        final mockData = [
          {
            'first_name': 'Juan',
            'last_name': 'Perez',
            'age': 30,
            'nationality': 'Siria',
            'vulnerability_score': 80.5,
            'gender': 'Male',
            'has_disability': false,
          },
          {
            'first_name': 'Maria',
            'last_name': 'Gomez',
            'age': 25,
            'nationality': 'Ucrania',
            'vulnerability_score': 60.0,
            'gender': 'Female',
            'has_disability': false,
          }
        ];
        return http.Response(json.encode(mockData), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify loading is gone and empty text is gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No hay refugiados sin asignar'), findsNothing);

      // Verify list and cards
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(RefugeeCard), findsNWidgets(2));
    });
  });
}
