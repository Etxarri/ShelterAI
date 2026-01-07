import 'package:flutter/material.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShelterAI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to ShelterAI',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Intelligent assignment of people to available shelters.'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('Add Refugee'),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(context, '/add_refugee');
                      if (result == true) _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text('Refugees'),
                    onPressed: () => Navigator.pushNamed(context, '/refugees'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Shelters'),
                    onPressed: () => Navigator.pushNamed(context, '/shelters'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),

            const Text('Quick Summary', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('refugees_count_$_refreshKey'),
              future: ApiService.getRefugees(),
              builder: (context, snap) {
                final count = snap.hasData ? snap.data!.length : null;
                return ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Total Refugees'),
                  subtitle: Text(count != null ? '$count registered' : 'loading...'),
                );
              },
            ),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getShelters(),
              builder: (context, snap) {
                final count = snap.hasData ? snap.data!.length : null;
                return ListTile(
                  leading: const Icon(Icons.house_outlined),
                  title: const Text('Available Shelters'),
                  subtitle: Text(count != null ? '$count registered' : 'loading...'),
                );
              },
            ),

            const SizedBox(height: 12),
            const Divider(),

            const Text('Quick Views', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),

            // show sample items
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getShelters(),
              builder: (context, snap) {
                final items = snap.data ?? [];
                if (items.isEmpty) return const SizedBox.shrink();
                // show first shelter as preview
                return ShelterCard(data: items.first);
              },
            ),

            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('refugee_preview_$_refreshKey'),
              future: ApiService.getRefugees(),
              builder: (context, snap) {
                final items = snap.data ?? [];
                if (items.isEmpty) return const SizedBox.shrink();
                return RefugeeCard(data: items.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
