import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/models/assignment.dart';
import 'package:shelter_ai/models/refugee.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';
import 'package:shelter_ai/screens/assignment_detail_screen.dart';

void main() {
  Widget createWidgetUnderTest(RefugeeAssignmentResponse response) {
    return MaterialApp(home: AssignmentDetailScreen(response: response));
  }

  testWidgets('AssignmentDetailScreen builds without error', (
    WidgetTester tester,
  ) async {
    final refugee = Refugee(id: 2, firstName: 'Jane', lastName: 'Doe', age: 25);
    final assignment = Assignment(
      id: 2,
      shelterId: 102,
      shelterName: 'North Refuge',
      priorityScore: 50.0,
      confidenceScore: 0.5,
      explanation: 'Reason',
      status: 'confirmed',
      assignedAt: DateTime.now(),
    );

    final response = RefugeeAssignmentResponse(
      refugee: refugee,
      assignment: assignment,
    );

    await tester.pumpWidget(createWidgetUnderTest(response));
    expect(find.byType(AssignmentDetailScreen), findsOneWidget);
  });
}
