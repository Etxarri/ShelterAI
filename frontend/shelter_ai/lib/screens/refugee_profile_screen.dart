import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';

class RefugeeProfileScreen extends StatefulWidget {
  const RefugeeProfileScreen({super.key});

  @override
  State<RefugeeProfileScreen> createState() => _RefugeeProfileScreenState();
}

class _RefugeeProfileScreenState extends State<RefugeeProfileScreen> {
  void _logout() {
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
        title: const Text('Tu espacio seguro'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hola, te acompañamos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text(auth.userName.isEmpty ? 'Refugiado registrado' : auth.userName),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.badge, size: 20),
                      const SizedBox(width: 8),
                      Text('ID: ${auth.userId ?? '-'}'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: const [
                      Icon(Icons.verified_user, size: 20),
                      SizedBox(width: 8),
                      Text('Sesión activa'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tus acciones rápidas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Ver o generar mi QR'),
              onPressed: () => Navigator.pushNamed(context, '/refugee_self'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: const Text('Qué pasará al llegar'),
              onPressed: () => _showSteps(context),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Pedir ayuda ahora'),
              onPressed: () => _showHelp(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'Consejos rápidos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _TipTile(
              icon: Icons.family_restroom,
              title: 'Si estás en familia',
              subtitle: 'Mantén a los menores contigo y muestra un solo QR por familia cuando sea posible.',
            ),
            const _TipTile(
              icon: Icons.medical_information,
              title: 'Salud primero',
              subtitle: 'Dolor, embarazo, alergias o movilidad reducida: avisa para priorizar tu atención.',
            ),
            const _TipTile(
              icon: Icons.lock_outline,
              title: 'Tus datos están protegidos',
              subtitle: 'Solo se usan para ubicarte y cuidarte. Puedes cerrar sesión cuando quieras.',
            ),
          ],
        ),
      ),
    );
  }

  void _showSteps(BuildContext context) {
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
              'Al llegar al centro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _StepItem(text: 'Muestra tu QR o tu nombre.'),
            _StepItem(text: 'Te asignaremos un lugar seguro.'),
            _StepItem(text: 'Si necesitas atención médica, dilo de inmediato.'),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ayuda urgente'),
        content: const Text(
          'Podemos priorizarte si hay dolor, embarazo, movilidad reducida, menores no acompañados o riesgo de seguridad.',
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

class _TipTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TipTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String text;

  const _StepItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.teal),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
