import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/auth_service.dart';

/// Helper class for authentication logic to avoid code duplication
class AuthHelper {
  /// Handles login and navigation after successful authentication
  static Future<void> handleLogin({
    required BuildContext context,
    required String identifier,
    required String password,
    required VoidCallback onLoadingStart,
    required VoidCallback onLoadingEnd,
  }) async {
    if (identifier.isEmpty || password.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email, phone or username and password required')),
        );
      }
      return;
    }

    onLoadingStart();

    try {
      final response = await AuthService.login(
        identifier: identifier,
        password: password,
      );

      if (!context.mounted) return;

      final auth = AuthScope.of(context);
      _processAuthResponse(auth, response, context);
    } catch (e) {
      onLoadingEnd();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  /// Processes authentication response and navigates to appropriate screen
  static void _processAuthResponse(
    AuthState auth,
    dynamic response,
    BuildContext context,
  ) {
    final roleEnum =
        response.role == 'worker' ? UserRole.worker : UserRole.refugee;

    // Extract first and last name if available
    String firstName = '';
    String lastName = '';
    if (response.name.contains(' ')) {
      final parts = response.name.split(' ');
      firstName = parts.first;
      lastName = parts.sublist(1).join(' ');
    } else {
      firstName = response.name;
    }

    auth.login(
      roleEnum,
      userId: response.userId,
      token: response.token,
      userName: response.name,
      firstName: firstName,
      lastName: lastName,
    );

    // Navigate based on role
    _navigateByRole(response.role, context);
  }

  /// Navigates to the appropriate screen based on user role
  static void _navigateByRole(String role, BuildContext context) {
    if (role == 'worker') {
      Navigator.pushReplacementNamed(context, '/worker-dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/refugee-profile');
    }
  }

  /// Handles worker registration
  static Future<void> handleWorkerRegister({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required VoidCallback onLoadingStart,
    required VoidCallback onLoadingEnd,
  }) async {
    onLoadingStart();

    try {
      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (!context.mounted) return;

      final auth = AuthScope.of(context);
      _processAuthResponse(auth, response, context);
    } catch (e) {
      onLoadingEnd();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e')),
      );
    }
  }

  /// Handles refugee registration and navigation
  static Future<void> handleRefugeeRegister({
    required BuildContext context,
    required Map<String, dynamic> refugeeData,
    required VoidCallback onLoadingStart,
    required VoidCallback onLoadingEnd,
  }) async {
    onLoadingStart();

    try {
      final response = await AuthService.registerRefugee(
        firstName: refugeeData['firstName'],
        lastName: refugeeData['lastName'],
        username: refugeeData['username'],
        email: refugeeData['email'],
        password: refugeeData['password'],
        phoneNumber: refugeeData['phoneNumber'],
        address: refugeeData['address'],
        age: refugeeData['age'],
        gender: refugeeData['gender'],
      );

      if (!context.mounted) return;

      final auth = AuthScope.of(context);
      final roleEnum =
          response.role == 'worker' ? UserRole.worker : UserRole.refugee;

      auth.login(
        roleEnum,
        userId: response.userId,
        token: response.token,
        userName: response.name,
        firstName: refugeeData['firstName'],
        lastName: refugeeData['lastName'],
        email: refugeeData['email'],
        phoneNumber: refugeeData['phoneNumber'],
        address: refugeeData['address'],
        age: refugeeData['age'],
        gender: refugeeData['gender'],
      );

      // Navigate to QR generation for refugees
      if (response.role == 'refugee') {
        Navigator.pushReplacementNamed(context, '/refugee-self-form-qr');
      } else {
        Navigator.pushReplacementNamed(context, '/worker-dashboard');
      }
    } catch (e) {
      onLoadingEnd();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration error: $e')),
      );
    }
  }
}
