import 'package:flutter/material.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/models/refugee_assignment_response.dart';
import 'package:shelter_ai/screens/assignment_detail_screen.dart';

class RefugeeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const RefugeeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Construir nombre completo
    final firstName = data['first_name'] ?? '';
    final lastName = data['last_name'] ?? '';
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isEmpty ? 'Sin nombre' : fullName;
    
    // Construir información de necesidades
    final age = data['age']?.toString() ?? '-';
    final specialNeeds = data['special_needs'] ?? '';
    final medicalConditions = data['medical_conditions'] ?? '';
    final hasDisability = data['has_disability'] == true ? 'Discapacidad' : '';
    
    // Combinar necesidades
    final needs = [specialNeeds, medicalConditions, hasDisability]
        .where((s) => s.isNotEmpty)
        .join(', ');
    final displayNeeds = needs.isEmpty ? 'Ninguna' : needs;
    
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: Text(
            firstName.isNotEmpty ? firstName[0].toUpperCase() : '?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Edad: $age • Necesidades: $displayNeeds'),
        trailing: IconButton(
          icon: Icon(Icons.analytics_outlined, color: Colors.blue),
          tooltip: 'Ver Asignación de IA',
          onPressed: () => _viewAssignment(context),
        ),
      ),
    );
  }

  Future<void> _viewAssignment(BuildContext context) async {
    final refugeeId = data['id'];
    
    if (refugeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se puede obtener la asignación')),
      );
      return;
    }

    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Obteniendo asignación...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Obtener las asignaciones del refugiado
      final assignments = await ApiService.getAssignments(refugeeId.toString());
      
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      if (assignments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Este refugiado no tiene asignación aún'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Tomar la primera asignación (la más reciente)
      final assignmentData = assignments.first;
      
      // Crear el objeto de respuesta
      final response = RefugeeAssignmentResponse.fromJson({
        'refugee': data,
        'assignment': assignmentData,
      });

      // Navegar a la pantalla de detalles
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AssignmentDetailScreen(response: response),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Cerrar loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener asignación: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
