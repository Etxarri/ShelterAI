import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';

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
        title: const Text('Llegaste a ShelterAI'),
        centerTitle: true,
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              tooltip: 'Cerrar sesión',
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
                    'Regístrate sin hacer cola',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Queremos que te sientas seguro. Comparte solo lo esencial y genera tu QR para que te reciban rápido.',
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
              onPressed: () => Navigator.pushNamed(context, '/refugee_self'),
              icon: const Icon(Icons.qr_code_2, size: 26),
              label: const Text('Registrarme y generar mi QR'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () => _showNextSteps(context),
              icon: const Icon(Icons.route),
              label: const Text('Ya tengo mi QR, ¿qué sigue?'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () => _showHelp(context),
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Necesito ayuda urgente'),
            ),
            const SizedBox(height: 28),
            Text(
              'Lo importante ahora',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.volunteer_activism,
              title: 'Te cuidamos desde el primer paso',
              body:
                  'Al registrarte nos ayudas a asignarte un espacio seguro y a cuidar tus necesidades médicas.',
            ),
            _InfoCard(
              icon: Icons.family_restroom,
              title: 'Si vienes en familia',
              body:
                  'Indica si viajas con menores o personas con movilidad reducida para mantenerlos juntos.',
            ),
            _InfoCard(
              icon: Icons.lock_outline,
              title: 'Tus datos, en confianza',
              body: 'Solo los usamos para tu protección y asignación. Puedes salir y volver; tu QR sigue vigente.',
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
              'Qué hacer al llegar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _StepRow(label: 'Muestra tu QR al trabajador'),
            _StepRow(label: 'Confirma tu nombre y acompáñanos'),
            _StepRow(label: 'Recibirás tu lugar y una guía breve'),
            SizedBox(height: 12),
            Text(
              'Si tienes dolor, estás con menores o necesitas apoyo de movilidad, avísanos de inmediato.',
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
        title: const Text('Ayuda inmediata'),
        content: const Text(
          'Dinos si necesitas atención médica, apoyo psicológico o un espacio seguro. Te atenderemos primero.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.primary.withOpacity(0.12)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;

  const _StepRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
