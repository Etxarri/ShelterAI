import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';

void main() {
  Widget _wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );
  }

  Map<String, dynamic> _baseRefugee({
    dynamic id = 1,
    String first = 'John',
    String last = 'Doe',
    int age = 30,
    String? specialNeeds,
    String? medical,
    bool hasDisability = false,
    dynamic assignedShelterId,
    String? status,
    String? shelterName,
    String? shelterAddress,
  }) {
    return {
      'id': id,
      'first_name': first,
      'last_name': last,
      'age': age,
      'special_needs': specialNeeds ?? '',
      'medical_conditions': medical ?? '',
      'has_disability': hasDisability,
      'assigned_shelter_id': assignedShelterId,
      'status': status,
      'shelter_name': shelterName,
      'shelter_address': shelterAddress,
    };
  }

  group('RefugeeCard coverage (robusto sin depender de ApiService JSON)', () {
    testWidgets('Unassigned: renderiza nombre, edad y needs', (tester) async {
      final data = _baseRefugee(
        assignedShelterId: null,
        status: null,
        specialNeeds: '',
        medical: '',
        hasDisability: false,
      );

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.textContaining('Age:'), findsOneWidget);
      expect(find.textContaining('Needs:'), findsOneWidget);
      expect(find.textContaining('None'), findsOneWidget);
      expect(find.byIcon(Icons.analytics_outlined), findsOneWidget);
    });

    testWidgets('Assigned: renderiza subtitle con shelter y address', (tester) async {
      final data = _baseRefugee(
        assignedShelterId: 99,
        status: 'assigned',
        shelterName: 'My Shelter',
        shelterAddress: 'Street 123',
      );

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.textContaining('📍 My Shelter'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('Assigned + id null: muestra error "Cannot view assignment"', (tester) async {
      final data = _baseRefugee(
        id: null,
        assignedShelterId: 99,
        status: 'assigned',
      );

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      await tester.tap(find.byIcon(Icons.location_on));
      await tester.pump();

      expect(find.text('Cannot view assignment'), findsOneWidget);
    });

    testWidgets('Unassigned + id null: muestra error "No se puede obtener la asignación"', (tester) async {
      final data = _baseRefugee(id: null);

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();

      expect(find.text('No se puede obtener la asignación'), findsOneWidget);
    });

    // ✅ FIX: no buscamos el texto del loading (aparece y desaparece demasiado rápido).
    // Solo verificamos que finalmente aparece el snackbar de error.
    testWidgets('Assigned: si API falla muestra snackbar error', (tester) async {
      final data = _baseRefugee(
        assignedShelterId: 99,
        status: 'assigned',
      );

      ApiService.client = MockClient((request) async {
        // deja un frame para que el dialog llegue a montarse en algunos entornos
        await Future<void>.delayed(const Duration(milliseconds: 1));
        return http.Response('boom', 500);
      });

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      await tester.tap(find.byIcon(Icons.location_on));

      // deja que corra el async + cierre el dialog + muestre snackbar
      await tester.pumpAndSettle();

      expect(find.textContaining('Error al cargar detalles:'), findsOneWidget);
    });

    testWidgets('Unassigned: si API falla muestra snackbar error', (tester) async {
      final data = _baseRefugee(id: 1);

      ApiService.client = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 1));
        return http.Response('boom', 500);
      });

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      await tester.tap(find.byIcon(Icons.analytics_outlined));

      await tester.pumpAndSettle();

      expect(find.textContaining('Error al obtener la asignación:'), findsOneWidget);
    });

    testWidgets('Nombre vacío => "No name" y avatar "?"', (tester) async {
      final data = _baseRefugee(first: '', last: '');

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      expect(find.text('No name'), findsOneWidget);
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('Needs combinados (special + medical + disability)', (tester) async {
      final data = _baseRefugee(
        specialNeeds: 'Wheelchair',
        medical: 'Asthma',
        hasDisability: true,
      );

      await tester.pumpWidget(_wrap(RefugeeCard(data: data)));

      expect(find.textContaining('Needs:'), findsOneWidget);
      expect(find.textContaining('Wheelchair'), findsOneWidget);
      expect(find.textContaining('Asthma'), findsOneWidget);
      expect(find.textContaining('Disability'), findsOneWidget);
    });
  });
}
