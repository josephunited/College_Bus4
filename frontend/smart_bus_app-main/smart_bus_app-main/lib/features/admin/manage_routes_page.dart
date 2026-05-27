import 'package:flutter/material.dart';
import '../../core/services/local_data_service.dart';

class ManageRoutesPage extends StatefulWidget {
  const ManageRoutesPage({super.key});

  @override
  State<ManageRoutesPage> createState() => _ManageRoutesPageState();
}

class _ManageRoutesPageState extends State<ManageRoutesPage> {
  bool _showMorning = true;

  static const BusStop _fallbackCollegeStop = BusStop(
    name: 'College',
    latitude: 0,
    longitude: 0,
    morningTime: '08:45',
    eveningTime: '16:45',
  );

  String _formatTo12Hour(String? time24) {
    if (time24 == null || time24.trim().isEmpty) {
      return '--:--';
    }

    final parts = time24.trim().split(':');
    if (parts.length != 2) {
      return time24;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || minute < 0 || minute > 59) {
      return time24;
    }

    final period = hour >= 12 ? 'PM' : 'AM';
    final normalizedHour = hour % 12 == 0 ? 12 : hour % 12;
    final minuteText = minute.toString().padLeft(2, '0');
    return '$normalizedHour:$minuteText $period';
  }

  bool _isCollegeStop(BusStop stop) {
    return stop.name.toLowerCase().contains('college');
  }

  List<BusStop> _morningStopsForRoute(BusRoute route) {
    final stops = List<BusStop>.from(route.stops);

    final collegeIndex = stops.indexWhere(_isCollegeStop);
    if (collegeIndex >= 0) {
      final college = stops.removeAt(collegeIndex);
      stops.add(college);
      return stops;
    }

    stops.add(_fallbackCollegeStop);
    return stops;
  }

  List<BusStop> _orderedStopsForMode(BusRoute route) {
    final morningStops = _morningStopsForRoute(route);
    if (_showMorning) {
      return morningStops;
    }
    return morningStops.reversed.toList(growable: false);
  }

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final routes = LocalDataService.allRoutes();
    final activeLabel = _showMorning ? 'Morning' : 'Evening';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: const Text('Manage Routes'),
        backgroundColor: const Color(0xFF2E1065),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Route Insights',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF18213A),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _showMorning = true;
                      });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _showMorning
                          ? const Color(0xFF6D28D9)
                          : Colors.transparent,
                      foregroundColor:
                          _showMorning ? Colors.white : const Color(0xFF4C1D95),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Morning'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _showMorning = false;
                      });
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: !_showMorning
                          ? const Color(0xFF6D28D9)
                          : Colors.transparent,
                      foregroundColor: !_showMorning
                          ? Colors.white
                          : const Color(0xFF4C1D95),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Evening'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...routes.map(
            (route) {
              final orderedStops = _orderedStopsForMode(route);
              final startName =
                  orderedStops.isEmpty ? route.busId : orderedStops.first.name;
              final endName =
                  orderedStops.isEmpty ? route.busId : orderedStops.last.name;

              return Card(
                child: ExpansionTile(
                  leading:
                      const Icon(Icons.alt_route, color: Color(0xFF6D28D9)),
                  title: Text(route.busId),
                  subtitle: Text('$startName -> $endName'),
                  children: orderedStops
                      .map(
                        (stop) => ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.location_on,
                            color: Color(0xFFEF4444),
                            size: 18,
                          ),
                          title: Text(stop.name),
                          subtitle: Text(
                            '$activeLabel: ${_formatTo12Hour(_showMorning ? stop.morningTime : stop.eveningTime)}',
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
