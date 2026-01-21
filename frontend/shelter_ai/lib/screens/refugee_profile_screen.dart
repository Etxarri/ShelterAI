import 'package:flutter/material.dart';
import '../widgets/custom_snackbar.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/models/recommendation_response.dart';
import 'package:shelter_ai/screens/recommendation_selection_screen.dart';
import 'package:shelter_ai/widgets/common_widgets.dart';

class RefugeeProfileScreen extends StatefulWidget {
  const RefugeeProfileScreen({super.key});

  @override
  State<RefugeeProfileScreen> createState() => _RefugeeProfileScreenState();
}

class _RefugeeProfileScreenState extends State<RefugeeProfileScreen>
    with LogoutMixin {
  Future<void> _handleCheckAssignment() async {
    final auth = AuthScope.of(context);
    final refugeeId = auth.userId;

    if (refugeeId == null) {
      CustomSnackBar.showError(
        context,
        'Refugee ID not found in session.',
      );
      return;
    }

    try {
      // Primero verificar si el backend indica que hay asignación generada
      final assignmentData =
          await ApiService.getRefugeeAssignment(refugeeId.toString());
      final hasAssignment = assignmentData['has_assignment'] as bool? ?? false;

      if (!hasAssignment) {
        if (!mounted) return;
        CustomSnackBar.showInfo(
          context,
          'You have not yet been assigned to any shelter.',
        );
        return;
      }

      // Si hay asignación generada, obtenemos las 3 opciones y abrimos la pantalla de selección
      final recommendationData =
          await ApiService.getAIRecommendation(refugeeId.toString());
      final recommendations =
          RecommendationResponse.fromJson(recommendationData);

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

      // Si seleccionó, puedes mostrar confirmación
      if (result == true && mounted) {
        CustomSnackBar.showSuccess(
          context,
          'You have successfully confirmed your shelter',
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.showError(
        context,
        'Error checking assignment: $e',
        duration: const Duration(seconds: 7),
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
            onPressed: logoutRefugee,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InfoCard(
              color: color.primaryContainer,
              border: Border.all(color: color.primary.withOpacity(0.2)),
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
                      Text(auth.userName.isEmpty
                          ? 'Registered refugee'
                          : auth.userName),
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
            const SizedBox(height: 24),
            const Text(
              'Your quick actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.qr_code),
              label: const Text('View or generate my QR'),
              onPressed: () =>
                  Navigator.pushNamed(context, '/refugee-self-form-qr'),
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
            const TipTile(
              icon: Icons.family_restroom,
              title: 'If you are with family',
              subtitle:
                  'Keep minors with you and show one QR per family when possible.',
            ),
            const TipTile(
              icon: Icons.medical_information,
              title: 'Health first',
              subtitle:
                  'Pain, pregnancy, allergies or reduced mobility: let us know to prioritize your care.',
            ),
            const TipTile(
              icon: Icons.lock_outline,
              title: 'Your data is protected',
              subtitle:
                  'We only use them to locate and care for you. You can log out whenever you want.',
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
              'Upon arriving at the shelter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            StepItem(text: 'Show your QR or your name.'),
            StepItem(text: 'We will assign you a safe place.'),
            StepItem(
                text: 'If you need medical attention, say so immediately.'),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request urgent help'),
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
