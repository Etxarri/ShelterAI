import 'package:flutter/material.dart';

class ShelterCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ShelterCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Refugio';
    final capacity = data['capacity'] ?? '-';
    final occupancy = data['occupancy'] ?? '-';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.house),
        title: Text(name),
        subtitle: Text('Capacidad: $capacity • Ocupación: $occupancy'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
