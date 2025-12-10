import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for Node-RED API - ajusta esto a tu configuración
  static const String baseUrl = 'http://localhost:1880/api';
  
  // 🔴 CAMBIO CLAVE: Creamos un cliente que podemos sustituir en los tests
  static http.Client client = http.Client();

  // GET /api/refugees - Obtener todos los refugiados
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
      // Devolver datos mock en caso de error para desarrollo
      return _getMockRefugees();
    }
  }

  // GET /api/refugees/:id - Obtener un refugiado específico
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

  // POST /api/refugees - Añadir un nuevo refugiado
  static Future<Map<String, dynamic>> addRefugee(Map<String, dynamic> refugee) async {
    try {
      final response = await client.post(Uri.parse('$baseUrl/refugees'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(refugee),
      );
      
      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to add refugee: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error adding refugee: $e');
      rethrow;
    }
  }

  // GET /api/shelters - Obtener todos los albergues
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
      // Devolver datos mock en caso de error
      return _getMockShelters();
    }
  }

  // GET /api/shelters/:id - Obtener un albergue específico
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

  // GET /api/shelters/available - Obtener albergues disponibles
  static Future<List<Map<String, dynamic>>> getAvailableShelters() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/shelters/available'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load available shelters: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching available shelters: $e');
      rethrow;
    }
  }

  // Datos mock para desarrollo/pruebas
  static List<Map<String, dynamic>> _getMockRefugees() {
    return [
      {'name': 'Amina', 'age': 29, 'needs': 'Médico'},
      {'name': 'Omar', 'age': 42, 'needs': 'Familiar'},
      {'name': 'Lina', 'age': 8, 'needs': 'Niña, escolar'},
    ];
  }

  static List<Map<String, dynamic>> _getMockShelters() {
    return [
      {'name': 'Refugio Central', 'capacity': 120, 'occupancy': 72},
      {'name': 'Albergue Norte', 'capacity': 60, 'occupancy': 55},
      {'name': 'Centro Temporal', 'capacity': 40, 'occupancy': 12},
    ];
  }
}
