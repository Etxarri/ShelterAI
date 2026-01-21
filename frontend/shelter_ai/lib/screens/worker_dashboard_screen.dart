import 'package:flutter/material.dart';
import 'package:shelter_ai/providers/auth_state.dart';
import 'package:shelter_ai/screens/qr_scan_screen.dart';
import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';
import 'package:shelter_ai/widgets/shelter_card.dart';
import 'package:shelter_ai/widgets/common_widgets.dart';
import 'dart:convert';

class WorkerDashboardScreen extends StatefulWidget {
  const WorkerDashboardScreen({super.key});

  @override
  State<WorkerDashboardScreen> createState() => _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen>
    with LogoutMixin {
  int _refreshKey = 0;

  void _refresh() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final color = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reception Panel'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: logoutWorker,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${auth.userName.isEmpty ? 'team' : auth.userName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Receive, assign and prioritize without wasting time. Scan or register manually.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionCard(
                  label: 'Scan QR',
                  icon: Icons.qr_code_scanner,
                  color: color.primary,
                  onTap: () async {
                    final raw = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrScanScreen()),
                    );
                    if (!mounted || raw == null) return;
                    _showScanResult(raw.toString());
                  },
                ),
                _ActionCard(
                  label: 'Manual registration',
                  icon: Icons.person_add_alt,
                  color: color.secondary,
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/add_refugee',
                    );
                    if (result == true && mounted) _refresh();
                  },
                ),
                _ActionCard(
                  label: 'Refugee list',
                  icon: Icons.people_alt,
                  color: Colors.teal.shade700,
                  onTap: () => Navigator.pushNamed(context, '/refugees'),
                ),
                _ActionCard(
                  label: 'Shelters and capacity',
                  icon: Icons.home_work,
                  color: Colors.indigo,
                  onTap: () => Navigator.pushNamed(context, '/shelters'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text(
              'Current situation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              key: ValueKey('refugees_count_$_refreshKey'),
              future: ApiService.getRefugees(),
              builder: (context, snap) {
                final count = snap.hasData ? snap.data!.length : null;
                return _StatTile(
                  icon: Icons.people_outline,
                  title: 'Registered people',
                  value: count != null ? '$count' : 'Loading...',
                );
              },
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: ApiService.getShelters(),
              builder: (context, snap) {
                final count = snap.hasData ? snap.data!.length : null;
                return _StatTile(
                  icon: Icons.home_outlined,
                  title: 'Available shelters',
                  value: count != null ? '$count' : 'Loading...',
                );
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Quick cases',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
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

  void _showScanResult(String data) {
    try {
      final Map<String, dynamic> map = jsonDecode(data) as Map<String, dynamic>;
      if (map.containsKey('first_name') || map.containsKey('firstName')) {
        Navigator.pushNamed(
          context,
          '/add_refugee',
          arguments: map,
        );
        return;
      }
    } catch (_) {
      // Not a refugee QR; fall back to dialog
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('QR received'),
        content: Text(
          data.length > 240 ? '${data.substring(0, 240)}…' : data,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
