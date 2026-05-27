import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/local_data_service.dart';
import 'manage_buses_page.dart';
import 'manage_routes_page.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  void _goBack(BuildContext context) {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final totalRoutes = LocalDataService.allRoutes().length;
    final totalStudents = LocalDataService.usersByRole(AppRole.student).length;
    final totalParents = LocalDataService.usersByRole(AppRole.parent).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: const Text('Admin Operations'),
        backgroundColor: const Color(0xFF2E1065),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Control Panel',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18213A),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatChip(label: 'Routes', value: '$totalRoutes'),
              _StatChip(label: 'Students', value: '$totalStudents'),
              _StatChip(label: 'Parents', value: '$totalParents'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManageBusesPage(),
                  ),
                );
              },
              leading: Icon(Icons.directions_bus, color: Colors.white),
              title: Text(
                'Manage Buses',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                'Create, assign and monitor fleet status',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.chevron_right, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ManageRoutesPage(),
                  ),
                );
              },
              leading: Icon(Icons.route, color: Color(0xFF6D28D9)),
              title: Text(
                'Manage Routes',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle:
                  Text('Add stops, edit timings, and publish route changes'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8FF),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Color(0xFF4C1D95),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
