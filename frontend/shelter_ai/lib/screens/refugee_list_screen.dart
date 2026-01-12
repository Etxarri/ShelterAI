import 'package:flutter/material.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';

class RefugeeListScreen extends StatefulWidget {
  const RefugeeListScreen({super.key});

  @override
  State<RefugeeListScreen> createState() => _RefugeeListScreenState();
}

class _RefugeeListScreenState extends State<RefugeeListScreen> {
  Future<List<Map<String, dynamic>>>? _refugeesFuture;

  @override
  void initState() {
    super.initState();
    _loadRefugees();
  }

  void _loadRefugees() {
    setState(() {
      _refugeesFuture = ApiService.getRefugees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Refugees')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _refugeesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) return const Center(child: Text('No data'));
          return RefreshIndicator(
            onRefresh: () async {
              _loadRefugees();
              await _refugeesFuture;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) => RefugeeCard(data: items[index]),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: items.length,
            ),
          );
        },
      ),
    );
  }
}
