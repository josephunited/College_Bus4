import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/local_data_service.dart';
import '../map/map_screen.dart';
import 'bus_eta_card.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
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
        title: const Text('Student Command Center'),
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
            bottom: 280,
            child: BusEtaCard(busId: etaBusId),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.30,
            minChildSize: 0.20,
            maxChildSize: 0.55,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F0FF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [BoxShadow(blurRadius: 14, color: Colors.black12)],
                ),
                child: ListView(
                  controller: controller,
                  children: [
                    Center(
                      child: Container(
                        height: 6,
                        width: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Live Bus Feed',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18213A),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _showMorning
                          ? 'Morning schedule - Track your route and service status'
                          : 'Evening schedule - Track your route and service status',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF60708E),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMorning = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: _showMorning
                                    ? const Color(0xFFA855F7)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFA855F7),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Morning',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _showMorning
                                      ? Colors.white
                                      : const Color(0xFFA855F7),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _showMorning = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 16),
                              decoration: BoxDecoration(
                                color: !_showMorning
                                    ? const Color(0xFFA855F7)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(0xFFA855F7),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Evening',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: !_showMorning
                                      ? Colors.white
                                      : const Color(0xFFA855F7),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFFE9D5FF),
                            child: Icon(Icons.directions_bus,
                                color: Color(0xFF6D28D9)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  route?.busId ?? 'Bus not assigned',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A2133),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  nextStop != null
                                      ? 'Next stop: ${nextStop.name} • Time: ${nextStopTime ?? '--:--'}'
                                      : 'No stops available',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF555B66),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFEDE9FE),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(99)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              child: Text(
                                'On Time',
                                style: TextStyle(
                                  color: Color(0xFF6D28D9),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (stops.isNotEmpty)
                      ...stops.take(8).map(
                            (stop) => Card(
                              child: ListTile(
                                leading: const Icon(Icons.location_on,
                                    color: Color(0xFFEF4444)),
                                title: Text(stop.name),
                                subtitle: Text(
                                  _showMorning
                                      ? 'Morning: ${stop.morningTime ?? '--:--'}'
                                      : 'Evening: ${stop.eveningTime ?? '--:--'}',
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
