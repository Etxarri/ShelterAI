import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';

void main() {
  group('ApiService Full Coverage Tests', () {
    // ----------------------------------------------------------------------
    // 1. TEST FOR REFUGEES (GET ALL)
    // ----------------------------------------------------------------------
    test(
      'getRefugees: Returns list from API if all goes well (200 OK)',
      () async {
        final mockClient = MockClient((request) async {
          return http.Response(
            json.encode([
              {'name': 'Familia Test', 'age': 30},
            ]),
            200,
          );
        });
        ApiService.client = mockClient;

        final result = await ApiService.getRefugees();
        expect(result.first['name'], 'Familia Test');
      },
    );

    // ----------------------------------------------------------------------
    // 2. TEST FOR SINGLE REFUGEE (GET BY ID)
    // ----------------------------------------------------------------------
    test('getRefugee: Returns a refugee by ID (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode({'id': '1', 'name': 'Omar'}), 200);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getRefugee('1');
      expect(result['name'], 'Omar');
    });

    test('getRefugee: Throws exception if fails (404 Not Found)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      ApiService.client = mockClient;

      expect(ApiService.getRefugee('99'), throwsException);
    });

    // ----------------------------------------------------------------------
    // 3. TEST FOR ADDING REFUGEE (POST)
    // ----------------------------------------------------------------------
    test('addRefugee: Works correctly (201 Created)', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST'); // Verify it's POST
        return http.Response(json.encode({'success': true}), 201);
      });
      ApiService.client = mockClient;

      final result = await ApiService.addRefugee({'name': 'Nuevo'});
      expect(result['success'], true);
    });

    test('addRefugee: Throws exception if server fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });
      ApiService.client = mockClient;

      expect(ApiService.addRefugee({'name': 'Nuevo'}), throwsException);
    });

    // ----------------------------------------------------------------------
    // 4. TEST FOR SHELTERS (GET ALL)
    // ----------------------------------------------------------------------
    test('getShelters: Returns list from API (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([
            {'name': 'Refugio Real', 'capacity': 100},
          ]),
          200,
        );
      });
      ApiService.client = mockClient;

      final result = await ApiService.getShelters();
      expect(result.first['name'], 'Refugio Real');
    });

    // ----------------------------------------------------------------------
    // 5. TEST FOR SINGLE SHELTER (GET BY ID)
    // ----------------------------------------------------------------------
    test('getShelter: Returns shelter by ID (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({'id': '10', 'name': 'Refugio X'}),
          200,
        );
      });
      ApiService.client = mockClient;

      final result = await ApiService.getShelter('10');
      expect(result['name'], 'Refugio X');
    });

    test('getShelter: Throws exception if fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });
      ApiService.client = mockClient;

      expect(ApiService.getShelter('10'), throwsException);
    });

    // ----------------------------------------------------------------------
    // 6. TEST FOR AVAILABLE SHELTERS
    // ----------------------------------------------------------------------
    test('getAvailableShelters: Returns list (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([
            {'name': 'Refugio Libre', 'occupancy': 0},
          ]),
          200,
        );
      });
      ApiService.client = mockClient;

      final result = await ApiService.getAvailableShelters();
      expect(result.first['name'], 'Refugio Libre');
    });

    test('getAvailableShelters: Throws exception if fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });
      ApiService.client = mockClient;

      expect(ApiService.getAvailableShelters(), throwsException);
    });

    // ----------------------------------------------------------------------
    // 7. TEST FOR ADD REFUGEE WITH ASSIGNMENT
    // ----------------------------------------------------------------------
    test(
      'addRefugeeWithAssignment: Returns response on success (201)',
      () async {
        final mockClient = MockClient((request) async {
          expect(request.method, 'POST');
          return http.Response(
            json.encode({
              'refugee': {'id': 1, 'first_name': 'Test'},
              'assignment': {'shelter_id': 10, 'shelter_name': 'Test Shelter'},
            }),
            201,
          );
        });
        ApiService.client = mockClient;

        final result = await ApiService.addRefugeeWithAssignment({
          'first_name': 'Test',
        });
        expect(result['refugee'], isNotNull);
        expect(result['assignment'], isNotNull);
      },
    );

    test('addRefugeeWithAssignment: Throws exception on error (500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });
      ApiService.client = mockClient;

      expect(
        ApiService.addRefugeeWithAssignment({'first_name': 'Test'}),
        throwsException,
      );
    });

    // ----------------------------------------------------------------------
    // 8. TEST FOR GET ASSIGNMENTS
    // ----------------------------------------------------------------------
    test('getAssignments: Returns list of assignments (200)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([
            {'shelter_id': 1, 'shelter_name': 'Shelter A'},
            {'shelter_id': 2, 'shelter_name': 'Shelter B'},
          ]),
          200,
        );
      });
      ApiService.client = mockClient;

      final result = await ApiService.getAssignments('123');
      expect(result.length, 2);
      expect(result.first['shelter_name'], 'Shelter A');
    });

    test('getAssignments: Throws exception on error (500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });
      ApiService.client = mockClient;

      expect(ApiService.getAssignments('123'), throwsException);
    });

    // ----------------------------------------------------------------------
    // 9. TEST EDGE CASES FOR ADD REFUGEE
    // ----------------------------------------------------------------------
    test('addRefugee: Handles empty response body', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 201);
      });
      ApiService.client = mockClient;

      final result = await ApiService.addRefugee({'name': 'Test'});
      expect(result['success'], true);
    });

    test('addRefugee: Handles empty array response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('[]', 201);
      });
      ApiService.client = mockClient;

      final result = await ApiService.addRefugee({'name': 'Test'});
      expect(result['success'], true);
    });

    test('addRefugee: Extracts first element from array response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode([
            {'id': 1, 'name': 'First'},
            {'id': 2, 'name': 'Second'},
          ]),
          201,
        );
      });
      ApiService.client = mockClient;

      final result = await ApiService.addRefugee({'name': 'Test'});
      expect(result['id'], 1);
      expect(result['name'], 'First');
    });
  });
}
