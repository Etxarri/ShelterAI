import 'package:flutter/material.dart';

class RefugeeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const RefugeeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(data['name'] ?? 'Sin nombre'),
        subtitle: Text('Edad: ${data['age'] ?? '-'} • Necesidades: ${data['needs'] ?? 'Ninguna'}'),
      ),
    );
  }
}
