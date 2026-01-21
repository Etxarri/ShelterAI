// File: test/widgets/refugee_card_full_coverage_test.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';

/// NavigatorObserver que cuenta pushes "reales" (pantallas),
/// ignorando diálogos (PopupRoute).
class TestNavObserver extends NavigatorObserver {
  int nonDialogPushCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    // AlertDialog / showDialog suelen ser PopupRoute
    if (route is PopupRoute) return;

    nonDialogPushCount++;
  }
}

Widget _wrap(Widget child, {NavigatorObserver? observer}) {
  return MaterialApp(
    navigatorObservers: observer != null ? [observer] : const [],
    home: Scaffold(body: child),
  );
}

Map<String, dynamic> _baseAssignedData({
  int? id = 1,
  String firstName = 'John',
  String lastName = 'Doe',
  int age = 30,
  String? shelterName = 'Fallback Shelter',
  String? shelterAddress = 'Fallback Address',
}) {
  return {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'age': age,
    'assigned_shelter_id': 99,
    'status': 'assigned',
    'shelter_name': shelterName,
    'shelter_address': shelterAddress,
    // needs fields (unused in assigned subtitle, but keep consistent)
    'special_needs': '',
    'medical_conditions': '',
    'has_disability': false,
  };
}

Map<String, dynamic> _baseUnassignedData({
  int? id = 2,
  String firstName = 'Jane',
  String lastName = 'Roe',
  int age = 22,
  String specialNeeds = 'Wheelchair',
  String medical = 'Asthma',
  bool hasDisability = true,
}) {
  return {
    'id': id,
    'first_name': firstName,
    'last_name': lastName,
    'age': age,
    'assigned_shelter_id': null,
    'status': 'pending',
    'special_needs': specialNeeds,
    'medical_conditions': medical,
    'has_disability': hasDisability,
  };
}

Map<String, dynamic> _assignmentJson({
  String shelterName = 'Shelter A',
  String status = 'assigned',
  double priorityScore = 80.0,
  String priorityLevel = 'High',
  double confidencePercentage = 92.0,
  String explanation = 'Because it matches the needs.',
}) {
  // OJO: no metas caracteres raros tipo "✓" para evitar el problema latin1/http.Response
  return {
    'shelter_name': shelterName,
    'status': status,
    'priority_score': priorityScore,
    'priority_level': priorityLevel,
    'confidence_percentage': confidencePercentage,
    'explanation': explanation,
    'matching_reasons': ['Close', 'Capacity'],
    'match_details': {'availability': 80, 'languages': 60},
    'alternative_shelters': [],
    'confidence': confidencePercentage,
  };
}

void main() {
  final nav = TestNavObserver();

    testWidgets('Unassigned: renderiza nombre, edad y needs + needs combinados',
        (tester) async {
      final data = _baseUnassignedData(
        firstName: 'Aiman',
        lastName: 'Saidi',
        age: 21,
        specialNeeds: 'Food',
        medical: 'Asthma',
        hasDisability: true,
      );

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      expect(find.text('Aiman Saidi'), findsOneWidget);
      // subtitle unassigned: Age: X • Needs: ...
      expect(find.textContaining('Age: 21'), findsOneWidget);
      expect(find.textContaining('Needs:'), findsOneWidget);
      // Debe incluir los 3 en needs
      expect(find.textContaining('Food'), findsOneWidget);
      expect(find.textContaining('Asthma'), findsOneWidget);
      expect(find.textContaining('Disability'), findsOneWidget);
    });

    testWidgets('Assigned: renderiza subtitle con shelter y address', (tester) async {
      final data = _baseAssignedData(
        shelterName: 'Shelter X',
        shelterAddress: 'Street 1',
      );

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      // En assigned: subtitle empieza con 📍
      expect(find.textContaining('📍 Shelter X'), findsOneWidget);
      expect(find.textContaining('Street 1'), findsOneWidget);
    });

    testWidgets('Nombre vacío => "No name" y avatar "?"', (tester) async {
      final data = _baseUnassignedData(firstName: '', lastName: '', id: 3);

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      expect(find.text('No name'), findsOneWidget);
      expect(find.text('?'), findsOneWidget); // avatar letter
    });

    testWidgets('Assigned + id null: muestra snackbar "Cannot view assignment"',
        (tester) async {
      final data = _baseAssignedData(id: null);

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));
      await tester.tap(find.byType(IconButton));
      await tester.pump(); // snackbar

      expect(find.text('Cannot view assignment'), findsOneWidget);
    });

    testWidgets('Unassigned + id null: muestra snackbar "No se puede obtener la asignación"',
        (tester) async {
      final data = _baseUnassignedData(id: null);

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));
      await tester.tap(find.byType(IconButton));
      await tester.pump(); // snackbar

      expect(find.text('No se puede obtener la asignación'), findsOneWidget);
    });

    testWidgets(
      'Assigned: assignments != [] => navega (push) a detalle',
      (tester) async {
        final data = _baseAssignedData(id: 20);

        final completer = Completer<http.Response>();
        ApiService.client = MockClient((req) {
          if (req.url.path.contains('assign')) {
            return completer.future;
          }
          return Future.value(http.Response('fail', 500));
        });

        await tester.pumpWidget(_wrap(RefugeeCard(data: data), observer: nav));

        final before = nav.nonDialogPushCount;

        // Tap icon -> abre loading y espera
        await tester.tap(find.byType(IconButton));
        await tester.pump(); // aparece dialog loading

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading details...'), findsOneWidget);

        // Responder con 1 assignment
        completer.complete(
          http.Response(jsonEncode([_assignmentJson(shelterName: 'Shelter A')]), 200),
        );

        await tester.pumpAndSettle();

        // IMPORTANTE: el push inicial (home) ya cuenta 1, por eso comprobamos +1
        expect(nav.nonDialogPushCount, before + 1);
      },
    );


    testWidgets(
      'Unassigned: assignments != [] => navega (push) a detalle sin pedir AI',
      (tester) async {
        final data = _baseUnassignedData(id: 30);

        final completer = Completer<http.Response>();
        ApiService.client = MockClient((req) {
          // La lógica del widget: primero getAssignments.
          if (req.url.path.contains('assign')) return completer.future;
          return Future.value(http.Response('fail', 500));
        });

        await tester.pumpWidget(_wrap(RefugeeCard(data: data), observer: nav));

        final before = nav.nonDialogPushCount;

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Getting AI recommendation...'), findsOneWidget);

        completer.complete(
          http.Response(jsonEncode([_assignmentJson(shelterName: 'Shelter Direct')]), 200),
        );

        await tester.pumpAndSettle();

        expect(nav.nonDialogPushCount, before + 1);
      },
    );

    testWidgets(
      // Para cubrir rama "pide AI" pero evitando el crash de AuthScope,
      // devolvemos error en AI y comprobamos snackbar.
      'Unassigned: assignments == [] => pide AI y (si AI falla) muestra snackbar (evita AuthScope crash)',
      (tester) async {
        final data = _baseUnassignedData(id: 31);

        final assignmentsCompleter = Completer<http.Response>();

        ApiService.client = MockClient((req) async {
          // 1) assignments -> []
          if (req.url.path.contains('assign')) {
            return assignmentsCompleter.future;
          }

          // 2) AI recommendation -> 404 para forzar catch y snackbar
          if (req.url.path.contains('recommend') ||
              req.url.path.contains('ai') ||
              req.url.path.contains('recom')) {
            return http.Response('not found', 404);
          }

          return http.Response('fail', 500);
        });

        await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

        await tester.tap(find.byType(IconButton));
        await tester.pump();

        // loading inicial (getting AI...)
        expect(find.text('Getting AI recommendation...'), findsOneWidget);

        // Responder assignments vacío
        assignmentsCompleter.complete(http.Response(jsonEncode([]), 200));

        await tester.pumpAndSettle();

        // Debe capturar error de AI y mostrar snackbar
        expect(find.textContaining('Error al obtener la asignación:'), findsOneWidget);
      },
    );

    
}
