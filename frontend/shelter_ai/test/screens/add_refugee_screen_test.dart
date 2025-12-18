import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/screens/add_refugee_screen.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(home: AddRefugeeScreen());
  }

  // Trick to make the screen huge so the whole form fits
  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
  }

  group('AddRefugeeScreen Tests', () {
    // TEST 1: Validation
    testWidgets('Shows validation errors if saved empty', (
      WidgetTester tester,
    ) async {
      setScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();

      expect(find.text('Required'), findsWidgets);
    });

    // TEST 2: Age Validation
    testWidgets('Shows error if age is invalid', (WidgetTester tester) async {
      setScreenSize(tester);
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '-5');

      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();

      expect(find.text('Invalid age'), findsOneWidget);
    });

    // TEST 3: SUCCESSFUL SUBMISSION (Happy Path)
    testWidgets('Submits form correctly and closes screen', (
      WidgetTester tester,
    ) async {
      setScreenSize(tester);

      // 1. Mock Server
      final mockClient = MockClient((request) async {
        final body = json.decode(request.body);
        if (body['first_name'] != null) {
          return http.Response(json.encode({'success': true}), 201);
        }
        return http.Response('Error', 400);
      });
      // Inject the mock
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // 2. Fill in the form
      await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'),
        'Juan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'),
        'Pérez',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '30');

      // Gender dropdown
      await tester.tap(
        find.widgetWithText(DropdownButtonFormField<String>, 'Gender'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Female').last);
      await tester.pumpAndSettle();

      // Rest of fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nationality'),
        'Spanish',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Languages (comma separated)'),
        'Spanish',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Medical Conditions'),
        'None',
      );

      await tester.tap(find.widgetWithText(SwitchListTile, 'Has Disability'));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vulnerability Score'),
        '85',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Special Needs'),
        'None',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Family ID (optional)'),
        '123',
      );

      // 3. Click Save
      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);

      // 4. Wait for response
      await tester.pumpAndSettle();
    });

    // TEST 4: Server Error
    testWidgets('Shows error SnackBar if API fails', (
      WidgetTester tester,
    ) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        return http.Response('Internal failure', 500);
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in only required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'),
        'Ana',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'),
        'García',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '25');

      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);

      await tester.pumpAndSettle();

      // Look for any message starting with Error
      expect(find.textContaining('Error:'), findsOneWidget);
      expect(find.byType(AddRefugeeScreen), findsOneWidget);
    });

    // TEST 5: Success dialog shows correctly
    testWidgets('Shows success dialog with refugee info', (
      WidgetTester tester,
    ) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'refugee': {
              'id': 1,
              'first_name': 'Maria',
              'last_name': 'Lopez',
              'age': 28,
            },
            'assignment': {
              'shelter_id': 5,
              'shelter_name': 'Central Shelter',
              'priority_score': 75.0,
              'confidence_score': 0.88,
              'reasons': ['Good match'],
            },
          }),
          201,
        );
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in required fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'),
        'Maria',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'),
        'Lopez',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '28');

      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Verify dialog appears with correct information
      expect(find.text('Refugee Registered'), findsOneWidget);
      expect(find.text('Maria Lopez'), findsOneWidget);
      expect(find.text('Central Shelter'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });

    // TEST 6: Close button works correctly
    testWidgets(
      'Close button dismisses dialog and returns to previous screen',
      (WidgetTester tester) async {
        setScreenSize(tester);

        final mockClient = MockClient((request) async {
          return http.Response(
            json.encode({
              'refugee': {
                'id': 1,
                'first_name': 'Carlos',
                'last_name': 'Rodriguez',
                'age': 35,
              },
              'assignment': {
                'shelter_id': 3,
                'shelter_name': 'North Shelter',
                'priority_score': 80.0,
                'confidence_score': 0.92,
                'reasons': ['Excellent match'],
              },
            }),
            201,
          );
        });
        ApiService.client = mockClient;

        await tester.pumpWidget(createWidgetUnderTest());

        // Fill in and save
        await tester.enterText(
          find.widgetWithText(TextFormField, 'First Name'),
          'Carlos',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Last Name'),
          'Rodriguez',
        );
        await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '35');

        final saveBtn = find.text('Save');
        await tester.ensureVisible(saveBtn);
        await tester.tap(saveBtn);
        await tester.pumpAndSettle();

        // Tap Close button
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Should not find the dialog anymore (navigated back)
        expect(find.text('Refugee Registered'), findsNothing);
      },
    );

    // TEST 7: View Details navigates to detail screen
    testWidgets('View Details button navigates to detail screen', (
      WidgetTester tester,
    ) async {
      setScreenSize(tester);

      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'refugee': {
              'id': 2,
              'first_name': 'Ana',
              'last_name': 'Martinez',
              'age': 42,
            },
            'assignment': {
              'shelter_id': 8,
              'shelter_name': 'South Shelter',
              'priority_score': 90.0,
              'confidence_score': 0.95,
              'reasons': ['Perfect match'],
            },
          }),
          201,
        );
      });
      ApiService.client = mockClient;

      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in and save
      await tester.enterText(
        find.widgetWithText(TextFormField, 'First Name'),
        'Ana',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Last Name'),
        'Martinez',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Age'), '42');

      final saveBtn = find.text('Save');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      // Tap View Details button
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      // Should navigate to different screen (dialog gone)
      expect(find.text('Refugee Registered'), findsNothing);
    });
  });
}
