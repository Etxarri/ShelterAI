import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';

void main() {
  group('ApiService Full Coverage Tests', () {
    
    // ----------------------------------------------------------------------
    // 1. TEST DE REFUGEES (GET ALL)
    // ----------------------------------------------------------------------
    test('getRefugees: Devuelve lista de API si todo va bien (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([
          {'name': 'Familia Test', 'age': 30}
        ]), 200);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getRefugees();
      expect(result.first['name'], 'Familia Test');
    });

    test('getRefugees: Devuelve DATOS MOCK (Backup) si la API falla', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error del servidor', 500);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getRefugees();
      
      // Verificamos que devuelve tus datos mock (Amina, Omar...)
      expect(result.length, 3);
      expect(result.first['name'], 'Amina');
    });

    // ----------------------------------------------------------------------
    // 2. TEST DE UN SOLO REFUGIADO (GET BY ID)
    // ----------------------------------------------------------------------
    test('getRefugee: Devuelve un refugiado por ID (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode({'id': '1', 'name': 'Omar'}), 200);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getRefugee('1');
      expect(result['name'], 'Omar');
    });

    test('getRefugee: Lanza excepción si falla (404 Not Found)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      ApiService.client = mockClient;

      expect(ApiService.getRefugee('99'), throwsException);
    });

    // ----------------------------------------------------------------------
    // 3. TEST DE AÑADIR REFUGIADO (POST)
    // ----------------------------------------------------------------------
    test('addRefugee: Funciona correctamente (201 Created)', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST'); // Verificamos que sea POST
        return http.Response(json.encode({'success': true}), 201);
      });
      ApiService.client = mockClient;

      final result = await ApiService.addRefugee({'name': 'Nuevo'});
      expect(result['success'], true);
    });

    test('addRefugee: Lanza excepción si falla el servidor', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error Interno', 500);
      });
      ApiService.client = mockClient;

      expect(ApiService.addRefugee({'name': 'Nuevo'}), throwsException);
    });

    // ----------------------------------------------------------------------
    // 4. TEST DE SHELTERS (GET ALL)
    // ----------------------------------------------------------------------
    test('getShelters: Devuelve lista de API (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([
          {'name': 'Refugio Real', 'capacity': 100}
        ]), 200);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getShelters();
      expect(result.first['name'], 'Refugio Real');
    });

    test('getShelters: Devuelve DATOS MOCK si falla (Backup)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 404);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getShelters();
      
      // Verificamos que devuelve tus datos mock (Refugio Central...)
      expect(result.length, 3);
      expect(result.first['name'], 'Refugio Central');
    });

    // ----------------------------------------------------------------------
    // 5. TEST DE UN SOLO SHELTER (GET BY ID)
    // ----------------------------------------------------------------------
    test('getShelter: Devuelve shelter por ID (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode({'id': '10', 'name': 'Refugio X'}), 200);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getShelter('10');
      expect(result['name'], 'Refugio X');
    });

    test('getShelter: Lanza excepción si falla', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });
      ApiService.client = mockClient;

      expect(ApiService.getShelter('10'), throwsException);
    });

    // ----------------------------------------------------------------------
    // 6. TEST DE SHELTERS DISPONIBLES
    // ----------------------------------------------------------------------
    test('getAvailableShelters: Devuelve lista (200 OK)', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode([
          {'name': 'Refugio Libre', 'occupancy': 0}
        ]), 200);
      });
      ApiService.client = mockClient;

      final result = await ApiService.getAvailableShelters();
      expect(result.first['name'], 'Refugio Libre');
    });

    test('getAvailableShelters: Lanza excepción si falla', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });
      ApiService.client = mockClient;

      expect(ApiService.getAvailableShelters(), throwsException);
    });

  });
}