import 'package:flutter/material.dart';

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
                    _ActionCard(
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
                    _ActionCard(
                      title: 'I already have an account',
                      description:
                          'Log in if you registered previously.',
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

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String actionLabel;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(description),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  ),
                  onPressed: onTap,
                  child: Text(actionLabel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
