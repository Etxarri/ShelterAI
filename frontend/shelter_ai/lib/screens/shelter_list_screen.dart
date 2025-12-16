import 'package:flutter/material.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';

class ShelterListScreen extends StatelessWidget {
  const ShelterListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refugios')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getShelters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No hay datos'));
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => ShelterCard(data: items[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
