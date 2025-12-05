import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/refugee_list_screen.dart';
import 'screens/shelter_list_screen.dart';
import 'screens/add_refugee_screen.dart';

void main() {
  runApp(const ShelterAIApp());
}

class ShelterAIApp extends StatelessWidget {
  const ShelterAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShelterAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/refugees': (context) => const RefugeeListScreen(),
        '/add_refugee': (context) => const AddRefugeeScreen(),
        '/shelters': (context) => const ShelterListScreen(),
      },
    );
  }
}
