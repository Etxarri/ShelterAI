import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL for Node-RED API - ajusta esto a tu configuración
  static const String baseUrl = 'http://localhost:1880/api';
  
  // GET /api/refugees - Obtener todos los refugiados
  static Future<List<Map<String, dynamic>>> getRefugees() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/refugees'));
      
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
      rethrow;
    }
  }

  // POST /api/refugees - Añadir un nuevo refugiado
  static Future<Map<String, dynamic>> addRefugee(Map<String, dynamic> refugee) async {
    try {
      // ignore: avoid_print
      print('Enviando datos: ${json.encode(refugee)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/refugees'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(refugee),
      );
      
      // ignore: avoid_print
      print('Código respuesta: ${response.statusCode}');
      // ignore: avoid_print
      print('Cuerpo respuesta: "${response.body}"');
      // ignore: avoid_print
      print('Longitud del cuerpo: ${response.body.length}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty || response.body.trim() == '[]') {
          // ignore: avoid_print
          print('Respuesta vacía o array vacío, retornando success');
          return {'success': true};
        }
        
        final decoded = json.decode(response.body);
        
        // Si es un array, tomar el primer elemento
        if (decoded is List) {
          if (decoded.isEmpty) {
            return {'success': true};
          }
          return decoded[0] as Map<String, dynamic>;
        }
        
        return decoded as Map<String, dynamic>;
      } else {
        throw Exception('Error al añadir refugiado: ${response.statusCode} - ${response.body}');
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
      final response = await http.get(Uri.parse('$baseUrl/shelters'));
      
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
      rethrow;
    }
  }
}
