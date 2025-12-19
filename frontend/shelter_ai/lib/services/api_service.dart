import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for Node-RED API - adjust this to your configuration
  static const String baseUrl = 'http://localhost:1880/api';

  // Create a client that we can replace in tests
  static http.Client client = http.Client();

  // GET /api/refugees - Get all refugees
  static Future<List<Map<String, dynamic>>> getRefugees() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/refugees'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load refugees: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching refugees: $e');
      rethrow;
    }
  }

  // GET /api/refugees/:id - Get a specific refugee
  static Future<Map<String, dynamic>> getRefugee(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/refugees/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load refugee: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching refugee: $e');
      rethrow;
    }
  }

  // POST /api/refugees - Add a new refugee (without assignment)
  static Future<Map<String, dynamic>> addRefugee(
    Map<String, dynamic> refugee,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/refugees'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(refugee),
      );

      // ignore: avoid_print
      print('Response code: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: "${response.body}"');
      // ignore: avoid_print
      print('Body length: ${response.body.length}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty || response.body.trim() == '[]') {
          // ignore: avoid_print
          print('Empty response or empty array, returning success');
          return {'success': true};
        }

        final decoded = json.decode(response.body);

        // If it's an array, take the first element
        if (decoded is List) {
          if (decoded.isEmpty) {
            return {'success': true};
          }
          return decoded[0] as Map<String, dynamic>;
        }

        return decoded as Map<String, dynamic>;
      } else {
        throw Exception('Failed to add refugee: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error adding refugee: $e');
      rethrow;
    }
  }

  // POST /api/refugees-with-assignment - Create refugee WITH automatic AI assignment
  static Future<Map<String, dynamic>> addRefugeeWithAssignment(
    Map<String, dynamic> refugee,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/refugees-with-assignment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(refugee),
      );

      // ignore: avoid_print
      print('Assignment response code: ${response.statusCode}');
      // ignore: avoid_print
      print('Assignment response body: "${response.body}"');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to add refugee with assignment: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error adding refugee with assignment: $e');
      rethrow;
    }
  }

  // GET /api/shelters - Get all shelters
  static Future<List<Map<String, dynamic>>> getShelters() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/shelters'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load shelters: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching shelters: $e');
      rethrow;
    }
  }

  // GET /api/shelters/:id - Get a specific shelter
  static Future<Map<String, dynamic>> getShelter(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/shelters/$id'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load shelter: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching shelter: $e');
      rethrow;
    }
  }

  // GET /api/shelters/available - Get available shelters
  static Future<List<Map<String, dynamic>>> getAvailableShelters() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/shelters/available'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception(
          'Failed to load available shelters: ${response.statusCode}',
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching available shelters: $e');
      rethrow;
    }
  }

  // GET /api/assignments/refugee/:refugeeId - Get assignments for a refugee
  static Future<List<Map<String, dynamic>>> getAssignments(
    String refugeeId,
  ) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/assignments/$refugeeId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load assignments: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching assignments: $e');
      rethrow;
    }
  }
}
