import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/home_screen.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }

  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('HomeScreen Tests', () {

    // ----------------------------------------------------------------------
    // TEST 1: BASIC SCREEN ELEMENTS
    // ----------------------------------------------------------------------
    testWidgets('Shows title and main buttons', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify the title is present
      expect(find.text('ShelterAI'), findsOneWidget);
      expect(find.text('Welcome to ShelterAI'), findsOneWidget);
      
      // Verify the three main buttons are present
      expect(find.text('Add Refugee'), findsOneWidget);
      expect(find.text('Refugees'), findsOneWidget);
      expect(find.text('Shelters'), findsOneWidget);
    });

    // ----------------------------------------------------------------------
    // TEST 2: QUICK SUMMARY WITH DATA
    // ----------------------------------------------------------------------
    testWidgets('Shows quick summary with data', (WidgetTester tester) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('refugees')) {
          return http.Response(json.encode([
            {
              'first_name': 'Juan',
              'last_name': 'Pérez',
              'age': 30,
              'nationality': 'Siria',
              'vulnerability_score': 80
            },
            {
              'first_name': 'María',
              'last_name': 'García',
              'age': 25,
              'nationality': 'Ucrania',
              'vulnerability_score': 60
            }
          ]), 200);
        } else if (request.url.toString().contains('shelters')) {
          return http.Response(json.encode([
            {
              'name': 'Refugio Central',
              'address': 'Calle Mayor 1',
              'max_capacity': 100,
              'current_occupancy': 50,
              'shelter_type': 'Temporal'
            }
          ]), 200);
        }
        return http.Response('[]', 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verify quick summary is displayed
      expect(find.text('Quick Summary'), findsOneWidget);
      expect(find.text('Total Refugees'), findsOneWidget);
      expect(find.text('2 registered'), findsOneWidget);
      expect(find.text('Available Shelters'), findsOneWidget);
      expect(find.text('1 registered'), findsOneWidget);

      // Verify quick views are displayed
      expect(find.text('Quick Views'), findsOneWidget);
      expect(find.byType(ShelterCard), findsOneWidget);
      expect(find.byType(RefugeeCard), findsOneWidget);
    });

    // ----------------------------------------------------------------------
    // TEST 3: EMPTY LIST
    // ----------------------------------------------------------------------
    testWidgets('Handles correctly when there is no data', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Counters should show 0
      expect(find.text('0 registered'), findsNWidgets(2));
      
      // Cards should not appear in quick views
      expect(find.byType(ShelterCard), findsNothing);
      expect(find.byType(RefugeeCard), findsNothing);
    });

    // ----------------------------------------------------------------------
    // TEST 4: NAVIGATION
    // ----------------------------------------------------------------------
    testWidgets('Navigation buttons work', (WidgetTester tester) async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([]), 200);
      });
      ApiService.client = mockClient;

      bool refugeesRouteVisited = false;
      bool sheltersRouteVisited = false;

      await tester.pumpWidget(MaterialApp(
        home: const HomeScreen(),
        routes: {
          '/add_refugee': (context) => const Scaffold(body: Text('Add Refugee Screen')),
          '/refugees': (context) {
            refugeesRouteVisited = true;
            return const Scaffold(body: Text('Refugees Screen'));
          },
          '/shelters': (context) {
            sheltersRouteVisited = true;
            return const Scaffold(body: Text('Shelters Screen'));
          },
        },
      ));
      await tester.pumpAndSettle();

      // Test navigation to refugees
      await tester.tap(find.text('Refugees'));
      await tester.pumpAndSettle();
      expect(refugeesRouteVisited, true);
      expect(find.text('Refugees Screen'), findsOneWidget);
    });

  });
}
