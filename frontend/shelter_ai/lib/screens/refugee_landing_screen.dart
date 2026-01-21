import 'package:flutter/material.dart';
import 'package:shelter_ai/widgets/action_card.dart';

class RefugeeLandingScreen extends StatefulWidget {
  const RefugeeLandingScreen({super.key});

  @override
  State<RefugeeLandingScreen> createState() => _RefugeeLandingScreenState();
}

class _RefugeeLandingScreenState extends State<RefugeeLandingScreen> {
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShelterAI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/welcome'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What do you want to do?',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Choose if you prefer to log in or create a new account to generate your QR.',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    ActionCard(
                      title: 'Create new account',
                      description:
                          'Register quickly, complete your information and generate your QR to access without waiting.',
                      icon: Icons.person_add,
                      color: color.primary,
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        '/refugee-register',
                      ),
                      actionLabel: 'Register',
                    ),
                    ActionCard(
                      title: 'I already have an account',
                      description: 'Log in if you registered previously.',
                      icon: Icons.login,
                      color: color.secondary,
                      onTap: () => Navigator.pushReplacementNamed(
                        context,
                        '/refugee-login',
                      ),
                      actionLabel: 'Sign in',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
