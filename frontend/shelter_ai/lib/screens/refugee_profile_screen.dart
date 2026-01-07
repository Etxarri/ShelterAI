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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu Información',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Nombre'),
                    subtitle: Text(auth.userName),
                  ),
                  ListTile(
                    leading: const Icon(Icons.badge),
                    title: const Text('ID'),
                    subtitle: Text('${auth.userId}'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.verified_user),
                    title: const Text('Estado'),
                    subtitle: const Text('Autenticado'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Mi QR de Registro',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('Generar QR'),
              onPressed: () => Navigator.pushNamed(context, '/refugee_self'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Opciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Información'),
              subtitle: const Text('Aprende cómo registrarte'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Completa el formulario y genera un QR para evitar colas',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Ayuda'),
              subtitle: const Text('¿Necesitas ayuda?'),
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Ayuda'),
                        content: const Text(
                          'Para registrarte en ShelterAI:\n\n'
                          '1. Completa tu formulario de registro\n'
                          '2. Genera tu QR\n'
                          '3. Muéstraselo a un trabajador\n'
                          '4. ¡Listo! Serás registrado sin colas',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Entendido'),
                          ),
                        ],
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
