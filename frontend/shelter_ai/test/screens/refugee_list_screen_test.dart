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
    // TEST 1: LOADING STATE (CircularProgressIndicator)
    // ----------------------------------------------------------------------
    testWidgets('Shows loading indicator while waiting for API', (WidgetTester tester) async {
      // Mock that takes a while to respond (to give us time to see loading)
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 500)); 
        return http.Response('[]', 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // 🛑 DO NOT use pumpAndSettle here, because we want to see "during", not "final".
      // Use pump(Duration) to advance just a little bit of time.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Now let it finish to clean up the test
      await tester.pumpAndSettle();
    });

    // ----------------------------------------------------------------------
    // TEST 2: EMPTY LIST ("No data")
    // ----------------------------------------------------------------------
    testWidgets('Shows message when there are no refugees', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200); // Empty list
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for loading to finish

      expect(find.text('No data'), findsOneWidget);
      expect(find.byType(RefugeeCard), findsNothing);
    });

    // ----------------------------------------------------------------------
    // TEST 3: WITH DATA (Shows RefugeeCards)
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
      await tester.pumpAndSettle(); // Wait for everything to paint

      // Verify loading is gone and empty text is gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No data'), findsNothing);

      // Verify there's a list and cards
      expect(find.byType(ListView), findsOneWidget);
      // Should have 2 RefugeeCard widgets
      expect(find.byType(RefugeeCard), findsNWidgets(2));
    });

  });
}