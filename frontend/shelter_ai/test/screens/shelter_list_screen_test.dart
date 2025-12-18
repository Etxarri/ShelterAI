import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/shelter_list_screen.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';

void main() {
  // Basic helper
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: ShelterListScreen());
  }

  // Helper for large screen (avoids overflow in lists)
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('ShelterListScreen Tests', () {
    // ----------------------------------------------------------------------
    // TEST 1: LOADING STATE (Loading)
    // ----------------------------------------------------------------------
    testWidgets('Shows loading while loading', (WidgetTester tester) async {
      // Mock that takes a while
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return http.Response('[]', 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // Only advance one frame, don't wait for finish (pump, NOT pumpAndSettle)
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up by finishing animation
      await tester.pumpAndSettle();
    });

    // ----------------------------------------------------------------------
    // TEST 2: EMPTY LIST (Empty State)
    // ----------------------------------------------------------------------
    testWidgets('Shows "No data" if the list is empty', (
      WidgetTester tester,
    ) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200); // Empty array
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle(); // Wait for everything to finish

      expect(find.text('No data'), findsOneWidget);
      expect(find.byType(ShelterCard), findsNothing);
    });

    // ----------------------------------------------------------------------
    // TEST 3: WITH DATA (Happy Path)
    // ----------------------------------------------------------------------
    testWidgets('Shows list of shelter cards', (WidgetTester tester) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        // Simulated shelter data with fields matching shelter_card
        final mockData = [
          {
            'name': 'Refugio Central',
            'address': 'Calle Mayor 1',
            'max_capacity': 100,
            'current_occupancy': 50,
            'shelter_type': 'Temporal',
          },
          {
            'name': 'Albergue Norte',
            'address': 'Av. Libertad 20',
            'max_capacity': 60,
            'current_occupancy': 10,
            'shelter_type': 'Permanente',
          },
        ];
        return http.Response(json.encode(mockData), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify loading and empty state are not shown
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No data'), findsNothing);

      // Verify cards are shown
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ShelterCard), findsNWidgets(2)); // Expect 2 cards

      // Optional: Verify a shelter name appears
      expect(find.text('Refugio Central'), findsOneWidget);
    });

    // ----------------------------------------------------------------------
    // TEST 4: ERROR STATE
    // ----------------------------------------------------------------------
    testWidgets('Shows error message if API fails', (
      WidgetTester tester,
    ) async {
      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assuming the screen shows "Error: Server Error" or similar SnackBar/Text
      // If it shows a SnackBar, we might need to look for it specifically.
      // Based on main.dart behavior or standard behavior:
      expect(find.textContaining('Error'), findsAtLeastNWidgets(1));
    });
  });
}
