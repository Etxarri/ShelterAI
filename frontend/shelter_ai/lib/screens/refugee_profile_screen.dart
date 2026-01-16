import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/models/recommendation_response.dart';
import 'package:shelter_ai/screens/recommendation_selection_screen.dart';

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

  Future<void> _handleCheckAssignment() async {
    final auth = AuthScope.of(context);
    final refugeeId = auth.refugeeId;  // ← CAMBIO: Usar refugeeId en lugar de userId

    if (refugeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el ID del refugiado en la sesión.')),
      );
      return;
    }

    try {
      // Opcional: comprobar asignación actual (no bloquea el flujo)
      // Ignoramos el resultado; siempre permitimos ver recomendaciones y elegir
      try {
        await ApiService.getRefugeeAssignment(refugeeId.toString());
      } catch (_) {
        // No interrumpe el flujo si falla
      }

      // Intentar obtener la última recomendación persistida
      late RecommendationResponse recommendations;
      final persistedRec = await ApiService.getLatestPersistedRecommendation(refugeeId.toString());
      
      if (persistedRec != null) {
        // Usar recomendación persistida
        recommendations = RecommendationResponse.fromJson(persistedRec);
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mostrando tus últimas recomendaciones guardadas.')),
        );
      } else {
        // Solicitar nuevas recomendaciones (se persistirán automáticamente)
        final recommendationData = await ApiService.getAIRecommendation(refugeeId.toString());
        recommendations = RecommendationResponse.fromJson(recommendationData);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se han generado nuevas recomendaciones para ti.')),
        );
      }

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecommendationSelectionScreen(
            refugeeId: int.parse(refugeeId.toString()),
            recommendationResponse: recommendations,
          ),
        ),
      );

      // Si seleccionó, mostrar confirmación
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Has confirmado tu refugio.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar asignación: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your safe space'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
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
                    'Hello, we are with you',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20),
                      const SizedBox(width: 8),
                      Text(auth.userName.isEmpty ? 'Registered refugee' : auth.userName),
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
                      Text('Active session'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botón para que el refugiado verifique su asignación y, si existe, elija entre las 3 opciones
            ElevatedButton.icon(
              icon: const Icon(Icons.home_work_outlined),
              label: const Text('Verificar mi asignación y elegir refugio'),
              onPressed: _handleCheckAssignment,
            ),
            const SizedBox(height: 24),
            const Text(
              'Your quick actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('View or generate my QR'),
              onPressed: () => Navigator.pushNamed(context, '/refugee-self-form-qr'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: const Text('What will happen upon arrival'),
              onPressed: () => _showSteps(context),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.health_and_safety),
              label: const Text('Request help now'),
              onPressed: () => _showHelp(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick tips',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const _TipTile(
              icon: Icons.family_restroom,
              title: 'If you are with family',
              subtitle: 'Keep minors with you and show one QR per family when possible.',
            ),
            const _TipTile(
              icon: Icons.medical_information,
              title: 'Health first',
              subtitle: 'Pain, pregnancy, allergies or reduced mobility: let us know to prioritize your care.',
            ),
            const _TipTile(
              icon: Icons.lock_outline,
              title: 'Your data is protected',
              subtitle: 'We only use them to locate and care for you. You can log out whenever you want.',
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
              'Upon arriving at the center',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _StepItem(text: 'Show your QR or your name.'),
            _StepItem(text: 'We will assign you a safe place.'),
            _StepItem(text: 'If you need medical attention, say so immediately.'),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Urgent help'),
        content: const Text(
          'We can prioritize you if there is pain, pregnancy, reduced mobility, unaccompanied minors or security risk.',
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
