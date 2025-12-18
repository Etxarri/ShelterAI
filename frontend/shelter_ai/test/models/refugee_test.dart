import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/models/refugee.dart';

void main() {
  group('Refugee Model Tests', () {
    test('Refugee.fromJson parses valid JSON correctly', () {
      final json = <String, dynamic>{
        'id': 1,
        'first_name': 'John',
        'last_name': 'Doe',
        'age': 30,
        'gender': 'Male',
        'nationality': 'Syrian',
        'languages_spoken': 'Arabic, English',
        'medical_conditions': 'None',
        'has_disability': true,
        'vulnerability_score': 8.5,
        'special_needs': 'Wheelchair',
        'family_id': 101,
        'created_at': '2023-01-01T12:00:00Z',
        'updated_at': '2023-01-02T12:00:00Z',
      };

      final refugee = Refugee.fromJson(json);

      expect(refugee.id, 1);
      expect(refugee.firstName, 'John');
      expect(refugee.lastName, 'Doe');
      expect(refugee.age, 30);
      expect(refugee.gender, 'Male');
      expect(refugee.nationality, 'Syrian');
      expect(refugee.languagesSpoken, 'Arabic, English');
      expect(refugee.medicalConditions, 'None');
      expect(refugee.hasDisability, isTrue);
      expect(refugee.vulnerabilityScore, 8.5);
      expect(refugee.specialNeeds, 'Wheelchair');
      expect(refugee.familyId, 101);
      expect(refugee.createdAt, DateTime.utc(2023, 1, 1, 12, 0, 0));
      expect(refugee.updatedAt, DateTime.utc(2023, 1, 2, 12, 0, 0));
    });

    test(
      'Refugee.fromJson parses non-standard types (String for int/double)',
      () {
        final json = <String, dynamic>{
          'id': '2', // String instead of int
          'first_name': 'Jane',
          'last_name': 'Smith',
          'age': '25', // String instead of int
          'vulnerability_score': '5', // String instead of double/int
          'has_disability': 'true', // String "true"
        };

        final refugee = Refugee.fromJson(json);

        expect(refugee.id, 2);
        expect(refugee.age, 25);
        expect(refugee.vulnerabilityScore, 5.0);
        expect(refugee.hasDisability, isTrue);
      },
    );

    test('Refugee.fromJson handles null values gracefully', () {
      final json = <String, dynamic>{
        // missing fields
      };

      final refugee = Refugee.fromJson(json);

      expect(refugee.id, isNull);
      expect(refugee.firstName, ''); // defaulted
      expect(refugee.lastName, ''); // defaulted
      expect(refugee.age, 0); // defaulted
      expect(refugee.gender, isNull);
      expect(refugee.hasDisability, isFalse); // default
      expect(refugee.vulnerabilityScore, 0.0); // default
      expect(refugee.createdAt, isNull);
    });

    test('toJson returns correct map', () {
      final refugee = Refugee(
        id: 1,
        firstName: 'John',
        lastName: 'Doe',
        age: 30,
        gender: 'Male',
        hasDisability: true,
        vulnerabilityScore: 8.5,
        familyId: 101,
      );

      final json = refugee.toJson();

      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['age'], 30);
      expect(json['gender'], 'Male');
      expect(json['has_disability'], true);
      expect(json['vulnerability_score'], 8.5);
      expect(json['family_id'], 101);
      // Optional fields are null
      expect(json['nationality'], isNull);
    });

    test('Getters work correctly', () {
      final refugee = Refugee(firstName: 'John', lastName: 'Doe', age: 30);

      expect(refugee.fullName, 'John Doe');
      expect(refugee.ageDisplay, '30 años');
    });

    test('Parses int as double for vulnerabilityScore', () {
      final json = <String, dynamic>{
        'id': 1,
        'first_name': 'A',
        'last_name': 'B',
        'age': 1,
        'vulnerability_score': 10, // int
      };

      final refugee = Refugee.fromJson(json);
      expect(refugee.vulnerabilityScore, 10.0);
    });

    test('Parses double as int for id/age if needed', () {
      final json = <String, dynamic>{
        'id': 1.0,
        'first_name': 'A',
        'last_name': 'B',
        'age': 20.0,
      };

      final refugee = Refugee.fromJson(json);
      expect(refugee.id, 1);
      expect(refugee.age, 20);
    });
  });
}
