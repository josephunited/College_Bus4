import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart' as ll;

import '../../core/services/api_service.dart';

class LiveBusGoogleMap extends StatefulWidget {
  const LiveBusGoogleMap(
      {super.key,
      this.busId = 1,
      this.staticMarkers = const <Marker>{},
      this.initialCenter});

  final int busId;
  final Set<Marker> staticMarkers;
  final LatLng? initialCenter;

  @override
  State<LiveBusGoogleMap> createState() => _LiveBusGoogleMapState();
}

class _LiveBusGoogleMapState extends State<LiveBusGoogleMap> {
  final ApiService _apiService = ApiService();

  GoogleMapController? _mapController;
  Timer? _timer;

  BusEta? _latestEta;
  LatLng busPosition = const LatLng(10.123, 76.123);
  Set<Marker> markers = <Marker>{};

  BitmapDescriptor _busIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueAzure,
  );

  bool _isLoading = true;
  String? _error;
  bool _isFetching = false;

  static const Duration _refreshInterval = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    busPosition = widget.initialCenter ?? busPosition;
    markers = _buildMarkersFor(busPosition);

    fetchETA();
    _startAutoRefresh();
    _loadBusIcon();
  }

  Future<void> _loadBusIcon() async {
    // You can replace this with a custom PNG asset if desired.
    _busIcon =
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant LiveBusGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.busId != widget.busId) {
      _timer?.cancel();
      _timer = null;
      _latestEta = null;
      _error = null;
      _isLoading = true;
      fetchETA();
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(_refreshInterval, (_) {
      fetchETA();
    });
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    return latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  Future<void> fetchETA() async {
    if (_isFetching) return;
    _isFetching = true;

    if (!mounted) {
      _isFetching = false;
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final eta = await _apiService.getBusEta(busId: widget.busId);
      if (!mounted) return;

      final latitude = eta.latitude;
      final longitude = eta.longitude;
      if (!_isValidCoordinate(latitude, longitude)) {
        debugPrint(
          'Skipping invalid coordinates from API -> lat: $latitude, lng: $longitude',
        );
        return;
      }

      final nextPosition = LatLng(latitude, longitude);
      debugPrint(
        'Live bus update -> lat: ${nextPosition.latitude}, lng: ${nextPosition.longitude}',
      );

      setState(() {
        _latestEta = eta;
        busPosition = nextPosition;
        markers = _buildMarkersFor(busPosition);
      });

      _focusCamera(nextPosition);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      _isFetching = false;
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Set<Marker> _buildMarkersFor(LatLng busPosition) {
    final updatedMarkers = <Marker>{...widget.staticMarkers};
    updatedMarkers.removeWhere((marker) => marker.markerId.value == 'bus');

    updatedMarkers.add(
      Marker(
        markerId: const MarkerId('bus'),
        position: busPosition,
        icon: _busIcon,
        anchor: const Offset(0.5, 0.5),
        infoWindow: InfoWindow(
          title: _latestEta?.nextStop ?? 'Live Bus',
          snippet: _latestEta == null
              ? ''
              : 'ETA: ${_latestEta!.etaMinutes.toStringAsFixed(2)} mins',
        ),
      ),
    );
    return updatedMarkers;
  }

  void _focusCamera(LatLng position) {
    if (_mapController == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16.0),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackCenter = widget.initialCenter ?? busPosition;

    if (kIsWeb) {
      return Stack(
        children: [
          fm.FlutterMap(
            options: fm.MapOptions(
              initialCenter:
                  ll.LatLng(fallbackCenter.latitude, fallbackCenter.longitude),
              initialZoom: 15,
            ),
            children: [
              fm.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smart_bus_app.app',
              ),
              fm.MarkerLayer(
                markers: [
                  fm.Marker(
                    point: ll.LatLng(
                        fallbackCenter.latitude, fallbackCenter.longitude),
                    width: 42,
                    height: 42,
                    child: const Icon(Icons.directions_bus,
                        color: Color(0xFF6D28D9), size: 30),
                  ),
                ],
              ),
            ],
          ),
          if (_isLoading && _latestEta == null)
            const Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Loading live bus position...'),
                    ],
                  ),
                ),
              ),
            ),
          if (_error != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Unable to fetch live bus data',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: fetchETA,
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: fallbackCenter,
            zoom: 15,
          ),
          markers: markers,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: true,
          onMapCreated: (controller) {
            _mapController = controller;
            setState(() {
              markers = _buildMarkersFor(busPosition);
            });
            _focusCamera(busPosition);
          },
        ),
        if (_isLoading && _latestEta == null)
          const Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading live bus position...'),
                  ],
                ),
              ),
            ),
          ),
        if (_error != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unable to fetch live bus data',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: fetchETA,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
