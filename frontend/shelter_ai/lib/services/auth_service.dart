import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelter_ai/services/api_service.dart'; // Importante

class LoginResponse {
  final bool success;
  final int userId;
  final String name;
  final String role;
  final String token;

  LoginResponse({
    required this.success,
    required this.userId,
    required this.name,
    required this.role,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // LOG DE DEPURACIÓN: Ver qué llega realmente
    // ignore: avoid_print
    print("Parsing JSON en Flutter: $json");

    // Construir nombre completo desde first_name y last_name
    String fullName = '';
    if (json['first_name'] != null || json['last_name'] != null) {
      fullName = '${json['first_name'] ?? ''} ${json['last_name'] ?? ''}'.trim();
    }

    return LoginResponse(
      // A veces Node-RED devuelve "success": "true" (string) o true (bool), esto cubre ambos
      success: json['success'] == true || json['success'] == 'true',
      userId: (json['user_id'] as int?) ?? (json['id'] as int?) ?? 0,
      // Usar first_name + last_name, o fallback a username
      name: fullName.isNotEmpty ? fullName : (json['username']?.toString() ?? 'Usuario'),
      role: json['role']?.toString() ?? 'refugee',
      token: json['token']?.toString() ?? '',
    );
  }
}

class AuthService {
  static const String baseUrl = 'http://localhost:1880/api';
  static const Duration _timeout = Duration(seconds: 10);

  /// Login flexible: puede ser con email, teléfono o usuario + contraseña
  /// Devuelve LoginResponse con role ('worker' o 'refugee')
  /// Lanza excepción si falla
  static Future<LoginResponse> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final response = await ApiService.client
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifier': identifier, // <--- ¡AQUÍ ESTÁN! No los borres.
              'password': password, // <--- Son vitales.
            }),
          )
          .timeout(_timeout);

      // ignore: avoid_print
      print('Login response: ${response.statusCode}');
      // ignore: avoid_print
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Incorrect credentials');
      } else {
        throw Exception(
          'Login error: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (_) {
      throw Exception(
        'Could not reach the backend. Is Node-RED running on localhost:1880?',
      );
    } on TimeoutException catch (_) {
      throw Exception('Request to backend timed out');
    } catch (e) {
      // ignore: avoid_print
      print('Login error: $e');
      rethrow;
    }
  }

  /// Registro para refugiados con todos los datos básicos
  /// ✅ IMPORTANTE: usa ApiService.client (así MockClient funciona en tests)
  static Future<LoginResponse> registerRefugee({
    required String firstName,
    required String lastName,
    required String username,
    String? email,
    required String password,
    String? phoneNumber,
    String? address,
    int? age,
    String? gender,
  }) async {
    try {
      final response = await ApiService.client
          .post(
            Uri.parse('$baseUrl/register-refugee'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'username': username,
              'email': email,
              'password': password,
              'phone_number': phoneNumber,
              'address': address,
              'age': age,
              'gender': gender,
            }),
          )
          .timeout(_timeout);

      // ignore: avoid_print
      print('Register refugee response: ${response.statusCode}');
      // ignore: avoid_print
      print('Register refugee body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception(
          'El backend no expone /api/register-refugee. Crea el endpoint en Node-RED.',
        );
      } else if (response.statusCode == 409) {
        throw Exception('El usuario ya existe');
      } else {
        throw Exception(
          'Error en registro: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (_) {
      throw Exception(
        'No se pudo conectar al backend. ¿Está levantado Node-RED en localhost:1880?',
      );
    } on TimeoutException catch (_) {
      throw Exception('Tiempo de espera agotado al contactar el backend');
    } catch (e) {
      // ignore: avoid_print
      print('Error register refugee: $e');
      rethrow;
    }
  }

  /// Registro para trabajadores
  static Future<LoginResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.client
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeout);

      // ignore: avoid_print
      print('Register response: ${response.statusCode}');
      // ignore: avoid_print
      print('Register body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return LoginResponse.fromJson(data);
      } else if (response.statusCode == 409) {
        throw Exception('El usuario ya existe');
      } else {
        throw Exception(
          'Error en registro: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException catch (_) {
      throw Exception(
        'No se pudo conectar al backend. ¿Está levantado Node-RED en localhost:1880?',
      );
    } on TimeoutException catch (_) {
      throw Exception('Tiempo de espera agotado al contactar el backend');
    } catch (e) {
      // ignore: avoid_print
      print('Error register: $e');
      rethrow;
    }
  }
}
