import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen> {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  void _logout() {
    final auth = AuthScope.of(context);
    auth.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShelterAI - Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bienvenido, ${auth.userName}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Panel de control para trabajadores'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person),
                    label: const Text('Registrar'),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/add_refugee',
                      );
                      if (result == true) _refresh();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people),
                    label: const Text('Refugiados'),
                    onPressed: () => Navigator.pushNamed(context, '/refugees'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Albergues'),
                    onPressed: () => Navigator.pushNamed(context, '/shelters'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const Text(
              'Resumen Rápido',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('refugees_count_$_refreshKey'),
              future: ApiService.getRefugees(),
              builder: (context, snap) {
                final count = snap.hasData ? snap.data!.length : null;
                return ListTile(
                  leading: const Icon(Icons.people_outline),
                  title: const Text('Refugiados Registrados'),
                  subtitle: Text(count != null ? '$count' : 'cargando...'),
                );
              },
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getShelters(),
              builder: (context, snap) {
                final count = snap.hasData ? snap.data!.length : null;
                return ListTile(
                  leading: const Icon(Icons.house_outlined),
                  title: const Text('Albergues Disponibles'),
                  subtitle: Text(count != null ? '$count' : 'cargando...'),
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(),
            const Text(
              'Vistas Rápidas',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getShelters(),
              builder: (context, snap) {
                final items = snap.data ?? [];
                if (items.isEmpty) return const SizedBox.shrink();
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
