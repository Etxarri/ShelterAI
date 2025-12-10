import 'package:flutter/material.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';

class RefugeeListScreen extends StatelessWidget {
  const RefugeeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refugiados')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ApiService.getRefugees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No hay datos'));
          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => RefugeeCard(data: items[index]),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
