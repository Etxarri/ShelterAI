import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      CustomSnackBar.showWarning(
        context,
        'Email, phone, username and password required',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.login(
        identifier: identifier,
        password: password,
      );

      if (!mounted) return;

      final auth = AuthScope.of(context);
      final roleEnum =
          response.role == 'worker' ? UserRole.worker : UserRole.refugee;

      // Extraer nombre y apellido si están en la respuesta
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

      // Navegar según rol
      if (response.role == 'worker') {
        Navigator.pushReplacementNamed(context, '/worker-dashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/refugee-profile');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x15000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Worker Access',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Receive, assign and prioritize securely.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _identifierCtrl,
                    decoration: InputDecoration(
                      labelText: 'Email, phone or username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.text,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.login),
                    label: Text(_isLoading ? 'Signing in...' : 'Sign in'),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(
                              context,
                              '/register',
                            ),
                    child: Text(
                      'First time? Create account',
                      style: TextStyle(color: color.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () => Navigator.pushReplacementNamed(
                              context,
                              '/welcome',
                            ),
                    child: const Text('Back to home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
