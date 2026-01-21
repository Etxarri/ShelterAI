import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/services/auth_service.dart';

void main() {
  late http.Client _oldClient;

  setUp(() {
    _oldClient = ApiService.client;
  });

  tearDown(() {
    ApiService.client = _oldClient;
  });

  group('LoginResponse.fromJson', () {
    test('success bool + fullName from first/last + user_id', () {
      final r = LoginResponse.fromJson({
        'success': true,
        'user_id': 7,
        'first_name': 'Aiman',
        'last_name': 'Saidi',
        'role': 'worker',
        'token': 'abc',
      });

      expect(r.success, true);
      expect(r.userId, 7);
      expect(r.name, 'Aiman Saidi');
      expect(r.role, 'worker');
      expect(r.token, 'abc');
    });

    test('success string "true" + fallback username + id', () {
      final r = LoginResponse.fromJson({
        'success': 'true',
        'id': 9,
        'username': 'tester',
      });

      expect(r.success, true);
      expect(r.userId, 9);
      expect(r.name, 'tester');
      expect(r.role, 'refugee');
      expect(r.token, '');
    });

    test('no names -> default Usuario + defaults', () {
      final r = LoginResponse.fromJson({'success': false});

      expect(r.success, false);
      expect(r.userId, 0);
      expect(r.name, 'Usuario');
      expect(r.role, 'refugee');
      expect(r.token, '');
    });
  });

  group('AuthService.login', () {
    test('200 -> returns LoginResponse', () async {
      ApiService.client = MockClient((request) async {
        expect(request.url.toString(), contains('/api/login'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['identifier'], 'user');
        expect(body['password'], 'pass');

        return http.Response(
          jsonEncode({
            'success': true,
            'user_id': 1,
            'first_name': 'John',
            'last_name': 'Doe',
            'role': 'refugee',
            'token': 't',
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final res = await AuthService.login(identifier: 'user', password: 'pass');
      expect(res.success, true);
      expect(res.userId, 1);
      expect(res.name, 'John Doe');
      expect(res.role, 'refugee');
      expect(res.token, 't');
    });

    test('201 -> returns LoginResponse', () async {
      ApiService.client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': 'true',
            'id': 2,
            'username': 'u2',
            'role': 'worker',
            'token': 'tok2',
          }),
          201,
        );
      });

      final res = await AuthService.login(identifier: 'x', password: 'y');
      expect(res.success, true);
      expect(res.userId, 2);
      expect(res.name, 'u2');
      expect(res.role, 'worker');
      expect(res.token, 'tok2');
    });

    test('401 -> throws Incorrect credentials', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      await expectLater(
        () => AuthService.login(identifier: 'u', password: 'p'),
        throwsA(predicate((e) => e.toString().contains('Incorrect credentials'))),
      );
    });

    test('other status -> throws Login error: code - body', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Boom', 500);
      });

      await expectLater(
        () => AuthService.login(identifier: 'u', password: 'p'),
        throwsA(predicate((e) => e.toString().contains('Login error: 500'))),
      );
    });

    test('SocketException -> friendly message', () async {
      ApiService.client = MockClient((request) async {
        throw const SocketException('nope');
      });

      await expectLater(
        () => AuthService.login(identifier: 'u', password: 'p'),
        throwsA(predicate(
          (e) => e.toString().contains('Could not reach the backend'),
        )),
      );
    });

    // ✅ Timeout REAL (sin FakeAsync) -> tarda > 10s y debe lanzar "Request to backend timed out"
    test(
      'TimeoutException -> Request to backend timed out',
      () async {
        ApiService.client = MockClient((request) async {
          await Future.delayed(const Duration(seconds: 11));
          return http.Response('[]', 200);
        });

        await expectLater(
          () => AuthService.login(identifier: 'u', password: 'p'),
          throwsA(predicate(
            (e) => e.toString().contains('Request to backend timed out'),
          )),
        );
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });

  group('AuthService.registerRefugee', () {
    test('201 -> returns LoginResponse', () async {
      ApiService.client = MockClient((request) async {
        expect(request.url.toString(), contains('/api/register-refugee'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['first_name'], 'A');
        expect(body['last_name'], 'B');
        expect(body['username'], 'ab');
        expect(body['password'], 'pw');

        return http.Response(
          jsonEncode({
            'success': true,
            'user_id': 11,
            'first_name': 'A',
            'last_name': 'B',
            'role': 'refugee',
            'token': 't11',
          }),
          201,
        );
      });

      final res = await AuthService.registerRefugee(
        firstName: 'A',
        lastName: 'B',
        username: 'ab',
        password: 'pw',
        email: 'a@b.com',
        phoneNumber: '123',
        address: 'addr',
        age: 20,
        gender: 'Male',
      );

      expect(res.success, true);
      expect(res.userId, 11);
      expect(res.name, 'A B');
      expect(res.role, 'refugee');
      expect(res.token, 't11');
    });

    test('200 -> returns LoginResponse', () async {
      ApiService.client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'id': 12,
            'username': 'u12',
            'token': 't12',
          }),
          200,
        );
      });

      final res = await AuthService.registerRefugee(
        firstName: 'A',
        lastName: 'B',
        username: 'u',
        password: 'pw',
      );

      expect(res.userId, 12);
      expect(res.name, 'u12');
    });

    test('404 -> throws backend no endpoint message', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Not found', 404);
      });

      await expectLater(
        () => AuthService.registerRefugee(
          firstName: 'A',
          lastName: 'B',
          username: 'u',
          password: 'pw',
        ),
        throwsA(predicate(
          (e) => e.toString().contains('no expone /api/register-refugee'),
        )),
      );
    });

    test('409 -> throws El usuario ya existe', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Conflict', 409);
      });

      await expectLater(
        () => AuthService.registerRefugee(
          firstName: 'A',
          lastName: 'B',
          username: 'u',
          password: 'pw',
        ),
        throwsA(predicate((e) => e.toString().contains('El usuario ya existe'))),
      );
    });

    test('other status -> throws Error en registro', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Bad', 500);
      });

      await expectLater(
        () => AuthService.registerRefugee(
          firstName: 'A',
          lastName: 'B',
          username: 'u',
          password: 'pw',
        ),
        throwsA(predicate((e) => e.toString().contains('Error en registro: 500'))),
      );
    });

    test('SocketException -> Spanish friendly message', () async {
      ApiService.client = MockClient((request) async {
        throw const SocketException('nope');
      });

      await expectLater(
        () => AuthService.registerRefugee(
          firstName: 'A',
          lastName: 'B',
          username: 'u',
          password: 'pw',
        ),
        throwsA(predicate(
          (e) => e.toString().contains('No se pudo conectar al backend'),
        )),
      );
    });

    // ✅ Timeout REAL (sin FakeAsync)
    test(
      'TimeoutException -> Tiempo de espera agotado',
      () async {
        ApiService.client = MockClient((request) async {
          await Future.delayed(const Duration(seconds: 11));
          return http.Response('ok', 200);
        });

        await expectLater(
          () => AuthService.registerRefugee(
            firstName: 'A',
            lastName: 'B',
            username: 'u',
            password: 'pw',
          ),
          throwsA(predicate(
            (e) => e.toString().contains('Tiempo de espera agotado'),
          )),
        );
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });

  group('AuthService.register (worker)', () {
    test('201 -> returns LoginResponse', () async {
      ApiService.client = MockClient((request) async {
        expect(request.url.toString(), contains('/api/register'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['name'], 'Worker');
        expect(body['email'], 'w@w.com');
        expect(body['password'], 'pw');

        return http.Response(
          jsonEncode({
            'success': true,
            'user_id': 21,
            'first_name': 'Worker',
            'last_name': 'One',
            'role': 'worker',
            'token': 'tw',
          }),
          201,
        );
      });

      final res = await AuthService.register(
        name: 'Worker',
        email: 'w@w.com',
        password: 'pw',
      );

      expect(res.success, true);
      expect(res.userId, 21);
      expect(res.name, 'Worker One');
      expect(res.role, 'worker');
    });

    test('409 -> throws El usuario ya existe', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Conflict', 409);
      });

      await expectLater(
        () => AuthService.register(name: 'W', email: 'e', password: 'p'),
        throwsA(predicate((e) => e.toString().contains('El usuario ya existe'))),
      );
    });

    test('other status -> throws Error en registro', () async {
      ApiService.client = MockClient((request) async {
        return http.Response('Bad', 500);
      });

      await expectLater(
        () => AuthService.register(name: 'W', email: 'e', password: 'p'),
        throwsA(predicate((e) => e.toString().contains('Error en registro: 500'))),
      );
    });

    test('SocketException -> Spanish friendly message', () async {
      ApiService.client = MockClient((request) async {
        throw const SocketException('nope');
      });

      await expectLater(
        () => AuthService.register(name: 'W', email: 'e', password: 'p'),
        throwsA(predicate(
          (e) => e.toString().contains('No se pudo conectar al backend'),
        )),
      );
    });

    // ✅ Timeout REAL (sin FakeAsync)
    test(
      'TimeoutException -> Tiempo de espera agotado',
      () async {
        ApiService.client = MockClient((request) async {
          await Future.delayed(const Duration(seconds: 11));
          return http.Response('ok', 200);
        });

        await expectLater(
          () => AuthService.register(name: 'W', email: 'e', password: 'p'),
          throwsA(predicate(
            (e) => e.toString().contains('Tiempo de espera agotado'),
          )),
        );
      },
      timeout: const Timeout(Duration(seconds: 15)),
    );
  });
}
