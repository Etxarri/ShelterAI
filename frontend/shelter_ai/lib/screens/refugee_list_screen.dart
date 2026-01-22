import 'package:flutter/material.dart';

import 'package:shelter_ai/services/api_service.dart';
import 'package:shelter_ai/widgets/refugee_card.dart';

class RefugeeListScreen extends StatefulWidget {
  const RefugeeListScreen({super.key});

  @override
  State<RefugeeListScreen> createState() => _RefugeeListScreenState();
}

class _RefugeeListScreenState extends State<RefugeeListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<Map<String, dynamic>>>? _unassignedFuture;
  Future<List<Map<String, dynamic>>>? _assignedFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRefugees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadRefugees() {
    setState(() {
      _unassignedFuture = ApiService.getRefugees();
      _assignedFuture = ApiService.getAssignedRefugees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refugees'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.person_outline),
              text: 'Unassigned',
            ),
            Tab(
              icon: Icon(Icons.check_circle_outline),
              text: 'Assigned',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Refugiados sin asignar
          _buildRefugeeList(_unassignedFuture, 'There are no unassigned refugees'),
          // Tab 2: Refugiados asignados
          _buildRefugeeList(_assignedFuture, 'There are no refugees assigned'),
        ],
      ),
    );
  }

  Widget _buildRefugeeList(
    Future<List<Map<String, dynamic>>>? future,
    String emptyMessage,
  ) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRefugees,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];
        
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadRefugees,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _loadRefugees();
            await future;
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => RefugeeCard(
              data: items[index],
              onAssignmentChanged: _loadRefugees,
            ),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          ),
        );
      },
    );
  }
}
