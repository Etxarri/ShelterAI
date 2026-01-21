import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/main.dart';

import 'package:shelter_ai/screens/assignment_detail_screen.dart';
import 'package:shelter_ai/screens/recommendation_selection_screen.dart';

void main() {
  /// Envuelve siempre con AuthScope + MaterialApp + Scaffold
  /// - Scaffold: SnackBars / dialogs
  /// - MaterialApp: Navigator
  /// - AuthScope: pantallas que usan AuthScope.of(context)
  Widget _wrap(Widget child, {AuthState? state}) {
    final auth = state ?? AuthState();

    // ✅ Siempre dejamos un usuario logueado (worker) para evitar fallos en pantallas
    auth.login(UserRole.worker, userId: 1, userName: 'Tester');

    return AuthScope(
      state: auth,
      child: MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('RefugeeCard Tests', () {
    testWidgets('Displays refugee information correctly', (tester) async {
      final refugeeData = {
        'id': 1,
        'first_name': 'John',
        'last_name': 'Doe',
        'age': 30,
        'special_needs': 'Food',
      };

      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.textContaining('Age: 30'), findsOneWidget);
      expect(find.textContaining('Needs:'), findsOneWidget);
    });

    testWidgets('Shows ? when first name is empty', (tester) async {
      final refugeeData = {'id': 1, 'first_name': '', 'last_name': 'Doe'};
      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      expect(find.text('?'), findsOneWidget);
      expect(find.text('Doe'), findsOneWidget);
    });

    testWidgets('Shows defaults when data is missing', (tester) async {
      final refugeeData = {'id': 1};
      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      expect(find.text('No name'), findsOneWidget);
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.textContaining('Needs:'), findsOneWidget);
    });

    testWidgets('Shows error SnackBar when id is null (unassigned flow)', (tester) async {
      final refugeeData = {
        // sin 'id'
        'first_name': 'John',
        'last_name': 'Doe',
      };

      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Texto real del widget
      expect(find.text('No se puede obtener la asignación'), findsOneWidget);
    });

    testWidgets('Shows error SnackBar when API fails (unassigned flow)', (tester) async {
      final refugeeData = {'id': 1, 'first_name': 'John', 'last_name': 'Doe'};

      ApiService.client = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });

      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.textContaining('Error al obtener la asignación:'), findsOneWidget);
    });

    testWidgets('Shows loading dialog while fetching AI recommendation', (tester) async {
      final refugeeData = {'id': 1, 'first_name': 'John', 'last_name': 'Doe'};

      ApiService.client = MockClient((request) async {
        if (request.url.path.contains('/assignments/')) {
          return http.Response(json.encode([]), 200);
        }
        if (request.url.path.contains('/ai/recommend/')) {
          await Future.delayed(const Duration(milliseconds: 300));
          return http.Response(json.encode(_fakeRecommendationJson()), 200);
        }
        return http.Response('[]', 200);
      });

      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Texto real del dialog (AI)
      expect(find.text('Getting AI recommendation...'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Navigates to RecommendationSelectionScreen when no assignments exist', (tester) async {
      final refugeeData = {'id': 1, 'first_name': 'John', 'last_name': 'Doe'};

      ApiService.client = MockClient((request) async {
        if (request.url.path.contains('/assignments/')) {
          return http.Response(json.encode([]), 200);
        }
        if (request.url.path.contains('/ai/recommend/')) {
          return http.Response(json.encode(_fakeRecommendationJson()), 200);
        }
        return http.Response('[]', 200);
      });

      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(RecommendationSelectionScreen), findsOneWidget);
    });

    testWidgets('Navigates to AssignmentDetailScreen when assignments exist (assigned flow)', (tester) async {
      final refugeeData = {
        'id': 1,
        'first_name': 'John',
        'last_name': 'Doe',
        // Esto fuerza isAssigned=true en RefugeeCard:
        'assigned_shelter_id': 10,
        'status': 'assigned',
        'shelter_name': 'Safe Haven',
        'shelter_address': 'Street 1',
      };

      ApiService.client = MockClient((request) async {
        if (request.url.path.contains('/assignments/')) {
          return http.Response(
            json.encode([
              {
                'id': 100,
                'shelter_id': 10,
                'shelter_name': 'Safe Haven',
                'priority_score': 80.0,
                'confidence_percentage': 95.0,
                'assigned_at': DateTime.now().toIso8601String(),
                'explanation': 'Good match',
                'status': 'confirmed',
                'matching_reasons': ['Reason 1'],
                'alternative_shelters': [],
              }
            ]),
            200,
          );
        }
        return http.Response('[]', 200);
      });

      await tester.pumpWidget(_wrap(RefugeeCard(data: refugeeData)));

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      expect(find.byType(AssignmentDetailScreen), findsOneWidget);
    });
  });
}

Map<String, dynamic> _fakeRecommendationJson() {
  return {
    "refugee_name": "John Doe",
    "refugee_age": 30,
    "refugee_nationality": "Test",
    "refugee_family_size": 1,
    "refugee_gender": "Male",
    "cluster_id": 1,
    "cluster_label": "A",
    "vulnerability_level": "High",
    "total_shelters_analyzed": 10,
    "ml_model_version": "1.0",
    "recommendations": [
      {
        "shelter_id": 101,
        "shelter_name": "Shelter One",
        "address": "Street 1",
        "compatibility_score": 90.0,
        "priority_score": 80,
        "max_capacity": 100,
        "current_occupancy": 50,
        "available_space": 50,
        "occupancy_rate": 0.5,
        "has_medical_facilities": true,
        "has_childcare": false,
        "has_disability_access": true,
        "explanation": "Good fit",
        "matching_reasons": ["Space"],
      }
    ],
  };
}
