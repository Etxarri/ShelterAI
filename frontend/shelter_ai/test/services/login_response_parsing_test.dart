import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/services/auth_service.dart';

void main() {
  group('LoginResponse.fromJson', () {
    test('success puede venir como bool o string "true"', () {
      final a = LoginResponse.fromJson({
        'success': true,
        'user_id': 1,
        'first_name': 'John',
        'last_name': 'Doe',
        'role': 'refugee',
        'token': 't',
      });

      final b = LoginResponse.fromJson({
        'success': 'true',
        'id': 2,
        'username': 'user',
        'role': 'worker',
        'token': 't2',
      });

      expect(a.success, true);
      expect(b.success, true);
      expect(a.userId, 1);
      expect(b.userId, 2);
    });

    test('name se construye con first_name + last_name si existen', () {
      final res = LoginResponse.fromJson({
        'success': true,
        'user_id': 10,
        'first_name': 'Aiman',
        'last_name': 'Saidi',
        'role': 'refugee',
        'token': 'x',
      });

      expect(res.name, 'Aiman Saidi');
    });

    test('si no hay first/last, usa username o "Usuario"', () {
      final withUsername = LoginResponse.fromJson({
        'success': true,
        'user_id': 1,
        'username': 'pepito',
        'role': 'refugee',
        'token': '',
      });
      expect(withUsername.name, 'pepito');

      final fallback = LoginResponse.fromJson({
        'success': true,
        'user_id': 1,
        'role': 'refugee',
      });
      expect(fallback.name, 'Usuario');
    });

    test('defaults: role refugee y token vacío si no viene', () {
      final res = LoginResponse.fromJson({
        'success': true,
        'user_id': 1,
      });

      expect(res.role, 'refugee');
      expect(res.token, '');
    });

    test('userId cae a 0 si no viene ni user_id ni id', () {
      final res = LoginResponse.fromJson({
        'success': true,
        'username': 'x',
      });
      expect(res.userId, 0);
    });
  });
}
