import 'package:flutter_test/flutter_test.dart';
import 'package:shelter_ai/providers/auth_state.dart';

void main() {
  group('AuthState', () {
    test('login() setea todos los campos y notifica listeners', () {
      final auth = AuthState();

      var notifications = 0;
      auth.addListener(() => notifications++);

      expect(auth.isAuthenticated, false);
      expect(auth.role, isNull);
      expect(auth.userId, isNull);
      expect(auth.token, '');
      expect(auth.userName, '');

      auth.login(
        UserRole.worker,
        userId: 7,
        token: 'tok',
        userName: 'Aiman',
        firstName: 'First',
        lastName: 'Last',
        age: 22,
        gender: 'Female',
        nationality: 'ES',
        email: 'a@a.com',
        phoneNumber: '123',
        address: 'Street',
      );

      expect(auth.isAuthenticated, true);
      expect(auth.role, UserRole.worker);
      expect(auth.userId, 7);
      expect(auth.token, 'tok');
      expect(auth.userName, 'Aiman');

      expect(auth.firstName, 'First');
      expect(auth.lastName, 'Last');
      expect(auth.age, 22);
      expect(auth.gender, 'Female');
      expect(auth.nationality, 'ES');
      expect(auth.email, 'a@a.com');
      expect(auth.phoneNumber, '123');
      expect(auth.address, 'Street');

      expect(notifications, 1);
    });

    test('logout() resetea todo y notifica listeners', () {
      final auth = AuthState();

      var notifications = 0;
      auth.addListener(() => notifications++);

      auth.login(
        UserRole.refugee,
        userId: 99,
        token: 'x',
        userName: 'User',
        firstName: 'F',
        lastName: 'L',
        age: 30,
        gender: 'Male',
        nationality: 'SY',
        email: 'e',
        phoneNumber: 'p',
        address: 'a',
      );

      expect(auth.isAuthenticated, true);

      auth.logout();

      expect(auth.isAuthenticated, false);
      expect(auth.role, isNull);
      expect(auth.userId, isNull);
      expect(auth.token, '');
      expect(auth.userName, '');

      expect(auth.firstName, '');
      expect(auth.lastName, '');
      expect(auth.age, isNull);
      expect(auth.gender, 'Male'); // vuelve al default
      expect(auth.nationality, isNull);
      expect(auth.email, isNull);
      expect(auth.phoneNumber, isNull);
      expect(auth.address, isNull);

      // 1 por login + 1 por logout
      expect(notifications, 2);
    });
  });
}
