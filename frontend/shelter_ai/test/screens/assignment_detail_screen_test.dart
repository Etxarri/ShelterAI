import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shelter_ai/screens/assignment_detail_screen.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => child),
    ),
  );
}

/// JSON helper: metemos a la vez snake_case y camelCase por si tu fromJson usa uno u otro.
/// (No molesta, y hace el test más robusto).
Map<String, dynamic> _minimalJson() {
  return {
    'refugee': {
      'id': 1,
      'first_name': 'John',
      'last_name': 'Doe',
      'age': 30,
      'nationality': null,
      'languages_spoken': null,
      'medical_conditions': null,
      'has_disability': false,
      'vulnerability_score': 50,
      'special_needs': null,

      // camelCase backup
      'firstName': 'John',
      'lastName': 'Doe',
      'hasDisability': false,
      'vulnerabilityScore': 50,
      'languagesSpoken': null,
      'medicalConditions': null,
      'specialNeeds': null,
    },
    'assignment': {
      'shelter_name': 'Shelter A',
      'status': 'pending',
      'priority_score': 65,
      'confidence_percentage': 72,
      'explanation': 'Because it is the best match.',
      'matching_reasons': [],
      'match_details': null,
      'alternative_shelters': [],

      // camelCase backup
      'shelterName': 'Shelter A',
      'priorityScore': 65,
      'confidencePercentage': 72,
      'matchingReasons': [],
      'matchDetails': null,
      'alternativeShelters': [],
    },
  };
}

Map<String, dynamic> _fullJson() {
  return {
    'refugee': {
      'id': 2,
      'first_name': 'Sara',
      'last_name': 'Ali',
      'age': 22,
      'nationality': 'Syrian',
      'languages_spoken': 'Arabic, English',
      'medical_conditions': 'Asthma',
      'has_disability': true,
      'vulnerability_score': 91,
      'special_needs': 'Wheelchair accessibility',

      // camelCase backup
      'firstName': 'Sara',
      'lastName': 'Ali',
      'hasDisability': true,
      'vulnerabilityScore': 91,
      'languagesSpoken': 'Arabic, English',
      'medicalConditions': 'Asthma',
      'specialNeeds': 'Wheelchair accessibility',
    },
    'assignment': {
      'shelter_name': 'Shelter B',
      'status': 'confirmed',
      'priority_score': 90,
      'confidence_percentage': 88,
      'explanation': 'High priority due to vulnerability and accessibility.',
      'matching_reasons': [
        '✓ Accessibility available',
        '✓ Medical staff on site',
      ],
      'match_details': {
        'medical_facilities': 85,
        'shelter_type': 55,
        'languages': 'good', // no-num para forzar rama score=0
        'availability': 10,  // score bajo
      },
      'alternative_shelters': [
        {'shelter_name': 'Alt Shelter 1', 'confidence_percentage': 61},
        {'shelter_name': 'Alt Shelter 2', 'confidence_percentage': 34},

        // camelCase backup dentro también
        {'shelterName': 'Alt Shelter 1', 'confidencePercentage': 61},
        {'shelterName': 'Alt Shelter 2', 'confidencePercentage': 34},
      ],

      // camelCase backup
      'shelterName': 'Shelter B',
      'priorityScore': 90,
      'confidencePercentage': 88,
      'matchingReasons': [
        '✓ Accessibility available',
        '✓ Medical staff on site',
      ],
      'matchDetails': {
        'medical_facilities': 85,
        'shelter_type': 55,
        'languages': 'good',
        'availability': 10,
      },
      'alternativeShelters': [
        {'shelterName': 'Alt Shelter 1', 'confidencePercentage': 61},
        {'shelterName': 'Alt Shelter 2', 'confidencePercentage': 34},
      ],
    },
  };
}

void main() {
  group('AssignmentDetailScreen', () {
    testWidgets('Render mínimo (sin recommendation / sin reasons / sin matchDetails / sin alternatives)', (tester) async {
      final response = RefugeeAssignmentResponse.fromJson(_minimalJson());

      await tester.pumpWidget(
        _wrap(
          AssignmentDetailScreen(
            response: response,
            isRecommendation: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Assignment for John Doe'), findsOneWidget);
      // "John Doe" aparece también en el body, así que deben ser 2 coincidencias
      expect(find.textContaining('John Doe'), findsNWidgets(2));

      expect(find.text('Assigned Shelter'), findsOneWidget);
      expect(find.text('Shelter A'), findsOneWidget);

      // No banner recommendation
      expect(
        find.text('This is an AI recommendation. No assignment has been created yet.'),
        findsNothing,
      );

      // Refugee info section
      expect(find.text('Refugee Information'), findsOneWidget);

      // No medical/special rows cuando vienen null
      expect(find.textContaining('Medical Conditions:'), findsNothing);
      expect(find.textContaining('Special Needs:'), findsNothing);

      // Back button (hay uno seguro abajo)
      expect(find.text('Back'), findsWidgets);
    });

    testWidgets('Render completo (recommendation + reasons + matchDetails + alternatives)', (tester) async {
      final response = RefugeeAssignmentResponse.fromJson(_fullJson());

      await tester.pumpWidget(
        _wrap(
          AssignmentDetailScreen(
            response: response,
            isRecommendation: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Banner recommendation
      expect(
        find.text('This is an AI recommendation. No assignment has been created yet.'),
        findsOneWidget,
      );

      // Header info
      expect(find.text('Sara Ali'), findsOneWidget);
      expect(find.textContaining('Syrian'), findsOneWidget);

      // Shelter + status
      expect(find.text('Shelter B'), findsOneWidget);
      expect(find.textContaining('Status:'), findsOneWidget);

      // Reasons
      expect(find.text('Assignment Reason'), findsOneWidget);
      expect(find.text('Why this shelter?'), findsOneWidget);
      expect(find.text('Accessibility available'), findsOneWidget);
      expect(find.text('Medical staff on site'), findsOneWidget);

      // Match criteria block
      expect(find.text('Match Criteria Analysis:'), findsOneWidget);
      expect(find.text('Medical Facilities'), findsOneWidget);
      expect(find.text('Shelter Type'), findsOneWidget);
      expect(find.text('Languages'), findsOneWidget);
      expect(find.text('Availability'), findsOneWidget);

      // Alternatives
      expect(find.text('Available Alternatives'), findsOneWidget);
      expect(find.text('Alt Shelter 1'), findsOneWidget);
      expect(find.text('Alt Shelter 2'), findsOneWidget);

      // Refugee info rows (medical/special/disability)
      expect(find.textContaining('Medical Conditions:'), findsOneWidget);
      expect(find.textContaining('Special Needs:'), findsOneWidget);
      expect(find.textContaining('Disability:'), findsOneWidget);

      // MatchDetails pinta progress bars
      expect(find.byType(LinearProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('Botón Back del bottom hace pop()', (tester) async {
      final response = RefugeeAssignmentResponse.fromJson(_minimalJson());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AssignmentDetailScreen(response: response),
                      ),
                    );
                  },
                  child: const Text('OPEN'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN'));
      await tester.pumpAndSettle();

      expect(find.text('Assigned Shelter'), findsOneWidget);

      // Tap Back del bottom (si hay varios "Back", este suele ser el de abajo)
      await tester.tap(find.text('Back').first);
      await tester.pumpAndSettle();

      expect(find.text('OPEN'), findsOneWidget);
    });
  });
}
