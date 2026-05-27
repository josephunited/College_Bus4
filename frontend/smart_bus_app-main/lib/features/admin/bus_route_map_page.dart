import 'package:flutter/material.dart';

import '../../core/services/local_data_service.dart';
import '../map/map_screen.dart';

class BusRouteMapPage extends StatelessWidget {
  const BusRouteMapPage({
    super.key,
    required this.route,
    required this.etaBusId,
  });

  final BusRoute route;
  final int etaBusId;

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: Text('Route Map • ${route.busId}'),
        backgroundColor: const Color(0xFF2E1065),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MapScreen(
            selectedBusId: etaBusId.toString(),
            routeStops: route.stops,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    route.busId,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    route.title,
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Stops: ${route.stops.length} • API Bus: $etaBusId',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
