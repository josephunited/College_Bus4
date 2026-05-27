import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/local_data_service.dart';
import '../map/map_screen.dart';
import '../student/bus_eta_card.dart';

class ParentHome extends StatefulWidget {
  const ParentHome({super.key});

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  bool _showMorning = true;

  void _goBack(BuildContext context) {
    context.go('/');
  }

  BusStop? _getNextStop(List<BusStop> stops) {
    if (stops.isEmpty) return null;
    // For evening mode, next stop is Vanchiyoor
    if (!_showMorning) {
      try {
        return stops.firstWhere(
          (stop) => stop.name.toLowerCase().contains('vanchiyoor'),
        );
      } catch (e) {
        return stops.isNotEmpty ? stops[0] : null;
      }
    }
    // For morning mode, return first stop
    return stops.isNotEmpty ? stops[0] : null;
  }

  String? _getNextStopTime(BusStop? stop) {
    if (stop == null) return null;
    return _showMorning ? stop.morningTime : stop.eveningTime;
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionService.currentUser;
    final route = LocalDataService.routeForBus(user?.busId);
    final stops = route?.stops ?? const [];
    final etaBusId = LocalDataService.etaApiBusIdForRoute(user?.busId);
    final nextStop = _getNextStop(stops);
    final nextStopTime = _getNextStopTime(nextStop);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _goBack(context);
          },
        ),
        title: const Text('Parent Control'),
        backgroundColor: const Color(0xFF2E1065),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          MapScreen(
            selectedBusId: etaBusId.toString(),
            routeStops: stops,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 220,
            child: BusEtaCard(busId: etaBusId),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 16, spreadRadius: 1)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Live Child Status',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF18213A),
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMorning = true;
                              });
                            },
                            child: Text(
                              'Morning',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _showMorning
                                    ? const Color(0xFF6D28D9)
                                    : const Color(0xFFB0B9C1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFB0B9C1),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMorning = false;
                              });
                            },
                            child: Text(
                              'Evening',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: !_showMorning
                                    ? const Color(0xFF6D28D9)
                                    : const Color(0xFFB0B9C1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFE9D5FF),
                        child: Icon(Icons.child_care, color: Color(0xFF6D28D9)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Child Bus: ${route?.busId ?? 'Not assigned'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nextStop != null
                                  ? 'Next stop: ${nextStop.name} • Time: ${nextStopTime ?? '--:--'}'
                                  : 'No stops available',
                              style: const TextStyle(color: Color(0xFF5B6470)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (user?.linkedStudent != null)
                    Text(
                      'Student: ${user!.linkedStudent}',
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
