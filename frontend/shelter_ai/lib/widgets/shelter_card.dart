import 'package:flutter/material.dart';

class ShelterCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ShelterCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Refugio';
    final maxCapacity = data['max_capacity'] ?? '-';
    final currentOccupancy = data['current_occupancy'] ?? 0;
    final shelterType = data['shelter_type'] ?? '';
    final address = data['address'] ?? '';
    
    // Calcular espacios disponibles
    final available = maxCapacity != '-' 
        ? (maxCapacity - currentOccupancy) 
        : '-';
    
    // Construir subtítulo con información relevante
    final typeInfo = shelterType.isNotEmpty ? '$shelterType • ' : '';
    final capacityInfo = 'Cap: $maxCapacity • Ocup: $currentOccupancy • Disp: $available';
    
    return Card(
      child: ListTile(
        leading: const Icon(Icons.house),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$typeInfo$capacityInfo'),
            if (address.isNotEmpty) 
              Text(
                address,
                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
