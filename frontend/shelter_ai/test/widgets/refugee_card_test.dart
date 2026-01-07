import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/widgets/refugee_card.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/assignment_detail_screen.dart';

void main() {
  group('RefugeeCard Tests', () {
    // TEST 1: Basic Rendering
    testWidgets('Displays refugee information correctly', (
      WidgetTester tester,
    ) async {
      final refugeeData = {
        'id': 1,
        'first_name': 'John',
        'last_name': 'Doe',
        'age': 30,
        'special_needs': 'Medical care',
        'medical_conditions': 'Diabetes',
        'has_disability': true,
      };

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(
        find.text('Age: 30 • Needs: Medical care, Diabetes, Disability'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    // TEST 2: Handles empty first name
    testWidgets('Shows ? when first name is empty', (
      WidgetTester tester,
    ) async {
      final refugeeData = {
        'id': 1,
        'first_name': '',
        'last_name': 'Doe',
        'age': 30,
      };

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      expect(find.text('?'), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
    });

    // TEST 3: Handles missing data
    testWidgets('Shows defaults when data is missing', (
      WidgetTester tester,
    ) async {
      final refugeeData = {'id': 1};

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      expect(find.text('No name'), findsOneWidget);
      expect(find.text('Age: - • Needs: None'), findsOneWidget);
    });

    // TEST 4: Error when ID is null
    testWidgets('Shows error SnackBar when id is null', (
      WidgetTester tester,
    ) async {
      final refugeeData = {'first_name': 'John', 'last_name': 'Doe'};

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();

      expect(find.text('Cannot get assignment'), findsOneWidget);
    });

    // TEST 5: Error when API fails
    testWidgets('Shows error when API fails', (WidgetTester tester) async {
      final refugeeData = {'id': 1, 'first_name': 'John', 'last_name': 'Doe'};

      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();
      await tester.pump(); // Loading dialog appears

      // Wait for the error
      await tester.pumpAndSettle();

      expect(find.textContaining('Error getting assignment'), findsOneWidget);
    });

    // TEST 6: Shows message when no assignments
    testWidgets('Shows message when refugee has no assignments', (
      WidgetTester tester,
    ) async {
      final refugeeData = {'id': 1, 'first_name': 'John', 'last_name': 'Doe'};

      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('This refugee has no assignment yet'), findsOneWidget);
    });

    // TEST 7: Navigates to detail screen on success
    testWidgets('Navigates to AssignmentDetailScreen on success', (
      WidgetTester tester,
    ) async {
      final refugeeData = {
        'id': 1,
        'first_name': 'John',
        'last_name': 'Doe',
        'age': 30,
      };

      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([
            {
              'shelter_id': 10,
              'shelter_name': 'Test Shelter',
              'priority_score': 85.0,
              'confidence_score': 0.95,
              'reasons': ['Good match'],
            },
          ]),
          200,
        );
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();
      await tester.pumpAndSettle();

      // Should navigate to AssignmentDetailScreen
      expect(find.byType(AssignmentDetailScreen), findsOneWidget);
    });

    // TEST 8: Shows loading dialog
    testWidgets('Shows loading dialog while fetching', (
      WidgetTester tester,
    ) async {
      final refugeeData = {'id': 1, 'first_name': 'John', 'last_name': 'Doe'};

      final mockClient = MockClient((request) async {
        await Future.delayed(Duration(milliseconds: 100));
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: RefugeeCard(data: refugeeData))),
      );

      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();
      await tester.pump(); // Show loading dialog

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Getting assignment...'), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
