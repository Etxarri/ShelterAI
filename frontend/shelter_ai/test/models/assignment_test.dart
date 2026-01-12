import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/models/assignment.dart';

void main() {
  group('Assignment Model Tests', () {
    test('Assignment.fromJson parses correctly', () {
      final json = <String, dynamic>{
        'id': 10,
        'shelter_id': 50,
        'shelter_name': 'Central Shelter',
        'priority_score': 85.5,
        'confidence_score': 0.95,
        'explanation': 'High match',
        'status': 'pending',
        'assigned_at': '2023-10-10 10:00:00',
        'alternative_shelters': [
          {
            'shelter_id': 51,
            'shelter_name': 'North Shelter',
            'confidence_score': 0.80,
          },
        ],
      };

      final assignment = Assignment.fromJson(json);

      expect(assignment.id, 10);
      expect(assignment.shelterId, 50);
      expect(assignment.shelterName, 'Central Shelter');
      expect(assignment.priorityScore, 85.5);
      expect(assignment.confidenceScore, 0.95);
      expect(assignment.explanation, 'High match');
      expect(assignment.status, 'pending');
      expect(assignment.assignedAt.year, 2023);
      expect(assignment.alternativeShelters.length, 1);
      expect(assignment.alternativeShelters.first.shelterName, 'North Shelter');
    });

    test('Helpers getters work correctly', () {
      final a1 = Assignment(
        id: 1,
        shelterId: 1,
        shelterName: 'S',
        priorityScore: 80, // High
        confidenceScore: 0.9,
        explanation: 'E',
        status: 'pending',
        assignedAt: DateTime.now(),
      );

      expect(a1.priorityLevel, 'Alta Prioridad');
      expect(a1.priorityColor, Colors.red);
      expect(a1.statusDisplay, 'Pendiente');
      expect(a1.statusIcon, Icons.hourglass_empty);
      expect(a1.statusColor, Colors.orange);
      expect(a1.confidencePercentage, 90.0);

      final a2 = Assignment(
        id: 2,
        shelterId: 1,
        shelterName: 'S',
        priorityScore: 50, // Medium
        confidenceScore: 0.5,
        explanation: 'E',
        status: 'confirmed',
        assignedAt: DateTime.now(),
      );

      expect(a2.priorityLevel, 'Prioridad Media');
      expect(a2.priorityColor, Colors.orange);
      expect(a2.statusDisplay, 'Confirmado');
      expect(a2.statusIcon, Icons.check_circle);
      expect(a2.statusColor, Colors.blue);

      final a3 = Assignment(
        id: 3,
        shelterId: 1,
        shelterName: 'S',
        priorityScore: 20, // Standard
        confidenceScore: 0.2,
        explanation: 'E',
        status: 'completed',
        assignedAt: DateTime.now(),
      );

      expect(a3.priorityLevel, 'Prioridad Estándar');
      expect(a3.priorityColor, Colors.green);
      expect(a3.statusDisplay, 'Completado');
      expect(a3.statusIcon, Icons.done_all);
      expect(a3.statusColor, Colors.green);
    });

    test('Default/Edge values', () {
      final json = <String, dynamic>{};
      final assignment = Assignment.fromJson(json);

      expect(assignment.id, 0);
      expect(assignment.status, 'pending');
      expect(assignment.alternativeShelters, isEmpty);
    });
  });
}
