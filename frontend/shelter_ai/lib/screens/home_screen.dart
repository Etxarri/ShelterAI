import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    final auth = AuthScope.of(context);
    auth.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to ShelterAI'),
        centerTitle: true,
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              tooltip: 'Logout',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.primaryContainer,
                    color.primaryContainer.withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Register without queuing',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We want you to feel safe. Share only the essentials and generate your QR to be received quickly.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () =>
                  Navigator.pushNamed(context, '/refugee-self-form-qr'),
              icon: const Icon(Icons.qr_code_2, size: 26),
              label: const Text('Register and generate my QR'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => _showNextSteps(context),
              icon: const Icon(Icons.route),
              label: const Text('I have my QR, what\'s next?'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showHelp(context),
              icon: const Icon(Icons.health_and_safety),
              label: const Text('I need urgent help'),
            ),
            const SizedBox(height: 28),
            Text(
              'What\'s important now',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const InfoTile(
              icon: Icons.volunteer_activism,
              title: 'We care for you from the first step',
              body:
                  'By registering, you help us assign you a safe space and take care of your medical needs.',
            ),
            const InfoTile(
              icon: Icons.family_restroom,
              title: 'If you come with family',
              body:
                  'Indicate if you travel with minors or people with reduced mobility to keep them together.',
            ),
            const InfoTile(
              icon: Icons.lock_outline,
              title: 'Your data, in confidence',
              body:
                  'We only use them for your protection and assignment. You can leave and return; your QR remains valid.',
            ),
          ],
        ),
      ),
    );
  }

  void _showNextSteps(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'What to do upon arrival',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            StepItem(text: 'Show your QR to the worker'),
            StepItem(text: 'Confirm your name and come with us'),
            StepItem(text: 'You will receive your place and a brief guide'),
            SizedBox(height: 12),
            Text(
              'If you are in pain, with minors, or need mobility support, let us know immediately.',
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Immediate help'),
        content: const Text(
          'Tell us if you need medical attention, psychological support, or a safe space. We will attend to you first.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }
}
