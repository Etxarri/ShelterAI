import 'package:flutter/material.dart';

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
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(displayName),
        subtitle: Text('Edad: $age • Necesidades: $displayNeeds'),
      ),
    );
  }
}
