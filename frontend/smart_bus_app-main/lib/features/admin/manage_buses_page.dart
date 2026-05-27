import 'package:flutter/material.dart';
import '../../core/services/local_data_service.dart';
import 'bus_route_map_page.dart';

class ManageBusesPage extends StatelessWidget {
  const ManageBusesPage({super.key});

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final routes = LocalDataService.allRoutes();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: const Text('Manage Buses'),
        backgroundColor: const Color(0xFF2E1065),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Active buses: ${routes.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...routes.map(
            (route) => Card(
              child: ListTile(
                onTap: () {
                  final etaBusId =
                      LocalDataService.etaApiBusIdForRoute(route.busId);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BusRouteMapPage(
                        route: route,
                        etaBusId: etaBusId,
                      ),
                    ),
                  );
                },
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE9D5FF),
                  child: Icon(Icons.directions_bus, color: Color(0xFF6D28D9)),
                ),
                title: Text(route.busId),
                subtitle: Text(
                  '${route.stops.length} stops • ${route.title}',
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
