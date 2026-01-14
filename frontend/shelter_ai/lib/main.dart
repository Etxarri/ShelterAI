import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'screens/home_screen.dart';
import 'screens/refugee_list_screen.dart';
import 'screens/shelter_list_screen.dart';
import 'screens/add_refugee_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/refugee_self_form_qr_screen.dart';
import 'screens/worker_dashboard_screen.dart';
import 'screens/refugee_profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/refugee_login_screen.dart';
import 'screens/refugee_register_screen.dart';
import 'screens/refugee_landing_screen.dart';

final AuthState _authState = AuthState();

void main() {
  runApp(const ShelterAIApp());
}

class ShelterAIApp extends StatelessWidget {
  const ShelterAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      state: _authState,
      child: MaterialApp(
        title: 'ShelterAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0C8A7B),
            secondary: const Color(0xFFF5A524),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FBFA),
          useMaterial3: true,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: const Color(0xFF12302D),
                displayColor: const Color(0xFF12302D),
              ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF12302D),
            elevation: 0,
          ),
        ),
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/': (context) => const WelcomeScreen(),
          '/refugee-landing': (context) => const RefugeeLandingScreen(),
          '/refugee-login': (context) => const RefugeeLoginScreen(),
          '/refugee-register': (context) => const RefugeeRegisterScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/worker-dashboard': (context) => const WorkerDashboardScreen(),
          '/refugee-profile': (context) => const RefugeeProfileScreen(),
          '/refugees': (context) => const RefugeeListScreen(),
          '/add_refugee': (context) => const AddRefugeeScreen(),
          '/shelters': (context) => const ShelterListScreen(),
          '/refugee-self-form-qr': (context) => const RefugeeSelfFormQrScreen(),
        },
      ),
    );
  }
}
