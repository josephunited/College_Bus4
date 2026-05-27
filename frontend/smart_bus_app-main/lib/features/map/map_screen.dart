import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import '../../core/services/api_service.dart';
import '../../core/services/local_data_service.dart';

const String kMapboxAccessToken =
    'YOUR_MAPBOX_TOKEN';

class MapScreen extends StatefulWidget {
  const MapScreen({
    super.key,
    this.selectedBusId,
    this.routeStops,
  });

  final String? selectedBusId;
  final List<BusStop>? routeStops;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  mb.MapboxMap? _mapboxMap;
  mb.PointAnnotationManager? _pointManager;
  mb.PolylineAnnotationManager? _polylineManager;
  Timer? _fetchTimer;
  bool _isFetching = false;

  List<LatLng> _busLocations = [];
  List<LatLng> _roadRoute = []; // ✅ REAL ROAD ROUTE

  List<BusStop> get _activeStops => widget.routeStops ?? [];

  LatLng get _initialCenter {
    if (_activeStops.isNotEmpty) {
      return LatLng(_activeStops.first.latitude, _activeStops.first.longitude);
    }
    return _defaultCenter;
  }

  static const LatLng _defaultCenter = LatLng(8.542636, 76.942068);
  static const Duration _liveRefreshInterval = Duration(seconds: 2);

  String _normalizeBusId(String? raw) {
    if (raw == null) return '';
    return raw.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  }

  bool _matchesSelectedBus({
    required String busId,
    required String? selectedBusId,
  }) {
    final selected = _normalizeBusId(selectedBusId);
    if (selected.isEmpty) return true;

    final current = _normalizeBusId(busId);
    if (current == selected) return true;

    final selectedDigits = selected.replaceAll(RegExp(r'\D'), '');
    final currentDigits = current.replaceAll(RegExp(r'\D'), '');
    if (selectedDigits.isNotEmpty && currentDigits == selectedDigits) {
      return true;
    }

    return false;
  }

  bool get _useFallbackMap {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  int _resolveApiBusId(String? selectedBusId) {
    final normalized = _normalizeBusId(selectedBusId);
    if (normalized.isEmpty) return 1;

    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 1;

    return int.tryParse(digits) ?? 1;
  }

  // ✅ LOAD ROAD ROUTE FROM MAPBOX
  Future<void> loadRoute() async {
    if (_activeStops.length < 2) return;

    try {
      final coords = await ApiService().getRouteGeometry(_activeStops);

      final route = coords
          .map((c) => LatLng(c[1], c[0])) // convert lng,lat → lat,lng
          .toList();

      print("Route points count: ${route.length}");

      if (!mounted) return;

      setState(() {
        _roadRoute = route;
      });

      await _renderMapboxRoute();
    } catch (e) {
      print("Route fetch error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadRoute(); // 🔥 IMPORTANT
    startFetching();
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final selectedBusChanged = oldWidget.selectedBusId != widget.selectedBusId;
    final routeChanged = oldWidget.routeStops != widget.routeStops;
    if (!selectedBusChanged && !routeChanged) {
      return;
    }

    _fetchTimer?.cancel();
    _fetchTimer = null;

    setState(() {
      _busLocations = <LatLng>[];
      _roadRoute = <LatLng>[];
    });

    loadRoute();
    startFetching();
  }

  void onMapCreated(mb.MapboxMap map) async {
    _mapboxMap = map;

    _pointManager =
        await _mapboxMap!.annotations.createPointAnnotationManager();
    _polylineManager =
        await _mapboxMap!.annotations.createPolylineAnnotationManager();

    await _renderMapboxMarkers(_busLocations);
    await _renderMapboxRoute();
  }

  Future<void> _renderMapboxRoute() async {
    if (_useFallbackMap || _polylineManager == null || _roadRoute.length < 2) {
      return;
    }

    await _polylineManager?.deleteAll();
    await _polylineManager?.create(
      mb.PolylineAnnotationOptions(
        geometry: {
          'type': 'LineString',
          'coordinates': _roadRoute
              .map((point) => [point.longitude, point.latitude])
              .toList(),
        },
        lineColor: 0xFF1D4ED8,
        lineWidth: 4.5,
      ),
    );
  }

  Future<void> _renderMapboxMarkers(List<LatLng> locations) async {
    if (_pointManager == null || _useFallbackMap) return;

    await _pointManager?.deleteAll();

    // Stops
    for (final stop in _activeStops) {
      await _pointManager?.create(
        mb.PointAnnotationOptions(
          geometry: {
            'type': 'Point',
            'coordinates': [stop.longitude, stop.latitude]
          },
          iconSize: 1.0,
        ),
      );
    }

    // Bus
    for (final point in locations) {
      await _pointManager?.create(
        mb.PointAnnotationOptions(
          geometry: {
            'type': 'Point',
            'coordinates': [point.longitude, point.latitude]
          },
          iconSize: 1.4,
        ),
      );
    }
  }

  Future<void> _fetchAndRenderBuses() async {
    if (_isFetching) return;

    _isFetching = true;

    try {
      final selectedBusId = widget.selectedBusId;
      final apiBusId = _resolveApiBusId(selectedBusId);
      final buses = await ApiService().getBusLocations(busId: apiBusId);
      final parsedLocations = <LatLng>[];

      for (final bus in buses) {
        final busId = bus.busId.trim();

        if (!_matchesSelectedBus(
          busId: busId,
          selectedBusId: selectedBusId,
        )) {
          continue;
        }

        if (!_isValidCoordinate(bus.latitude, bus.longitude)) {
          print(
              '⚠️ Skipping invalid bus coordinates: lat=${bus.latitude}, lng=${bus.longitude}');
          continue;
        }

        final busPosition = LatLng(bus.latitude, bus.longitude);
        parsedLocations.add(busPosition);
        print('🚌 BUS UPDATE: lat=${bus.latitude}, lng=${bus.longitude}');
      }

      if (!mounted) return;

      setState(() {
        _busLocations = parsedLocations;
      });

      print(
          '📍 Markers recreated. Total bus locations: ${parsedLocations.length}');
      await _renderMapboxMarkers(parsedLocations);
    } catch (e) {
      print('❌ Bus fetch error: $e');
    } finally {
      _isFetching = false;
    }
  }

  void startFetching() {
    _fetchTimer?.cancel();

    _fetchAndRenderBuses();

    _fetchTimer =
        Timer.periodic(_liveRefreshInterval, (_) => _fetchAndRenderBuses());
    print('⏰ Bus location polling started (every 2 seconds)');
  }

  @override
  void dispose() {
    _fetchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FALLBACK MAP (Windows/Web)
    if (_useFallbackMap) {
      return SizedBox.expand(
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _initialCenter,
            initialZoom: 13,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smart_bus_app.app',
            ),

            // ✅ REAL ROAD ROUTE
            if (_roadRoute.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _roadRoute,
                    strokeWidth: 4,
                    color: const Color(0xFF1D4ED8),
                  ),
                ],
              ),

            // Markers
            MarkerLayer(
              markers: [
                // Stops
                ..._activeStops.map(
                  (stop) => Marker(
                    point: LatLng(stop.latitude, stop.longitude),
                    width: 120,
                    height: 50,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 4)
                            ],
                          ),
                          child: Text(
                            stop.name,
                            style: const TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.location_on,
                            color: Color(0xFFEF4444), size: 22),
                      ],
                    ),
                  ),
                ),

                // Bus
                ..._busLocations.map(
                  (point) => Marker(
                    point: point,
                    width: 42,
                    height: 42,
                    child: const Icon(
                      Icons.directions_bus,
                      color: Color(0xFF1D4ED8),
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // ✅ MAPBOX (Android/iOS)
    return SizedBox.expand(
      child: mb.MapWidget(
        resourceOptions: mb.ResourceOptions(accessToken: kMapboxAccessToken),
        cameraOptions: mb.CameraOptions(
          center: {
            'type': 'Point',
            'coordinates': [_initialCenter.longitude, _initialCenter.latitude]
          } as Map<String, Object?>,
          zoom: 13.0,
        ),
        styleUri: mb.MapboxStyles.MAPBOX_STREETS,
        onMapCreated: onMapCreated,
      ),
    );
  }
}
