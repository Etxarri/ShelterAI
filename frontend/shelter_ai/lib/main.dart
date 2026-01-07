import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/refugee_list_screen.dart';
import 'screens/shelter_list_screen.dart';
import 'screens/add_refugee_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/refugee_self_form_qr_screen.dart';
import 'screens/worker_dashboard_screen.dart';
import 'screens/refugee_profile_screen.dart';
import 'providers/auth_state.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/': (context) => const HomeScreen(),
          '/worker-dashboard': (context) => const WorkerDashboardScreen(),
          '/refugee-profile': (context) => const RefugeeProfileScreen(),
          '/refugees': (context) => const RefugeeListScreen(),
          '/add_refugee': (context) => const AddRefugeeScreen(),
          '/shelters': (context) => const ShelterListScreen(),
          '/refugee_self': (context) => const RefugeeSelfFormQrScreen(),
        },
      ),
    );
  }
}
