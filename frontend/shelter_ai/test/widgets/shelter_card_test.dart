import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';

void main() {
  group('ShelterCard Tests', () {
    testWidgets('Renders different shelter types colors', (
      WidgetTester tester,
    ) async {
      final shelterDataPermanent = {
        'name': 'Perm',
        'max_capacity': 10,
        'current_occupancy': 0,
        'shelter_type': 'Permanente',
      };
      final shelterDataTemp = {
        'name': 'Temp',
        'max_capacity': 10,
        'current_occupancy': 0,
        'shelter_type': 'Temporal',
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ShelterCard(data: shelterDataPermanent),
                ShelterCard(data: shelterDataTemp),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Perm'), findsOneWidget);
      expect(find.text('Temp'), findsOneWidget);
    });
  });
}
