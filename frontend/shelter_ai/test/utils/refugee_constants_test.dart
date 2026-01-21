import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/utils/refugee_constants.dart';

void main() {
  group('RefugeeConstants', () {
    test('nationalities list is not empty', () {
      expect(RefugeeConstants.nationalities, isNotEmpty);
      expect(RefugeeConstants.nationalities.length, greaterThan(10));
    });

    test('nationalities contains expected values', () {
      expect(RefugeeConstants.nationalities, contains('Afghan'));
      expect(RefugeeConstants.nationalities, contains('Syrian'));
      expect(RefugeeConstants.nationalities, contains('Ukrainian'));
      expect(RefugeeConstants.nationalities, contains('Other'));
    });

    test('languages list is not empty', () {
      expect(RefugeeConstants.languages, isNotEmpty);
      expect(RefugeeConstants.languages.length, greaterThan(10));
    });

    test('languages contains expected values', () {
      expect(RefugeeConstants.languages, contains('Arabic'));
      expect(RefugeeConstants.languages, contains('Spanish'));
      expect(RefugeeConstants.languages, contains('English'));
      expect(RefugeeConstants.languages, contains('Other'));
    });

    test('medicalConditions list is not empty', () {
      expect(RefugeeConstants.medicalConditions, isNotEmpty);
      expect(RefugeeConstants.medicalConditions.length, greaterThan(10));
    });

    test('medicalConditions contains expected values', () {
      expect(RefugeeConstants.medicalConditions, contains('Asthma'));
      expect(RefugeeConstants.medicalConditions, contains('Diabetes'));
      expect(RefugeeConstants.medicalConditions, contains('Pregnancy'));
      expect(RefugeeConstants.medicalConditions, contains('Other'));
    });

    test('specialNeedsList list is not empty', () {
      expect(RefugeeConstants.specialNeedsList, isNotEmpty);
      expect(RefugeeConstants.specialNeedsList.length, greaterThan(5));
    });

    test('specialNeedsList contains expected values', () {
      expect(RefugeeConstants.specialNeedsList,
          contains('Psychological support'));
      expect(RefugeeConstants.specialNeedsList, contains('Family space'));
      expect(
          RefugeeConstants.specialNeedsList, contains('Medical supervision'));
      expect(RefugeeConstants.specialNeedsList, contains('Other'));
    });

    test('all lists end with "Other" option', () {
      expect(RefugeeConstants.nationalities.last, 'Other');
      expect(RefugeeConstants.languages.last, 'Other');
      expect(RefugeeConstants.medicalConditions.last, 'Other');
      expect(RefugeeConstants.specialNeedsList.last, 'Other');
    });

    test('no duplicate values in nationalities', () {
      final set = RefugeeConstants.nationalities.toSet();
      expect(set.length, RefugeeConstants.nationalities.length);
    });

    test('no duplicate values in languages', () {
      final set = RefugeeConstants.languages.toSet();
      expect(set.length, RefugeeConstants.languages.length);
    });

    test('no duplicate values in medicalConditions', () {
      final set = RefugeeConstants.medicalConditions.toSet();
      expect(set.length, RefugeeConstants.medicalConditions.length);
    });

    test('no duplicate values in specialNeedsList', () {
      final set = RefugeeConstants.specialNeedsList.toSet();
      expect(set.length, RefugeeConstants.specialNeedsList.length);
    });
  });
}
