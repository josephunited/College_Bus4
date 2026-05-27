import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'local_data_service.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class BusEta {
  const BusEta({
    required this.busId,
    required this.nextStop,
    required this.distanceKm,
    required this.etaMinutes,
    required this.latitude,
    required this.longitude,
  });

  final int busId;
  final String nextStop;
  final double distanceKm;
  final double etaMinutes;
  final double latitude;
  final double longitude;

  static double _doubleOr(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  factory BusEta.fromJson(Map<String, dynamic> json) {
    final latitude = _doubleOr(json['latitude'], 0.0);
    final longitude = _doubleOr(json['longitude'], 0.0);

    return BusEta(
      busId: (json['bus_id'] as num?)?.toInt() ?? 0,
      nextStop: (json['next_stop'] as String?) ?? 'Unknown',
      distanceKm: _doubleOr(json['distance_km'], 0.0),
      etaMinutes: _doubleOr(json['eta_minutes'], 0.0),
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class LiveBusLocation {
  const LiveBusLocation({
    required this.busId,
    required this.latitude,
    required this.longitude,
  });

  final String busId;
  final double latitude;
  final double longitude;

  static LiveBusLocation? fromDynamic(dynamic raw) {
    if (raw is! Map) return null;

    final map = Map<String, dynamic>.from(raw.cast<Object?, Object?>());

    final busIdRaw =
        map['bus_id'] ?? map['busId'] ?? map['id'] ?? map['vehicle_id'];
    final latRaw = map['lat'] ?? map['latitude'];
    final lngRaw = map['lng'] ?? map['lon'] ?? map['longitude'];

    final lat = _toDouble(latRaw);
    final lng = _toDouble(lngRaw);
    if (lat == null || lng == null) return null;

    final busId = (busIdRaw ?? '').toString().trim();
    return LiveBusLocation(
      busId: busId.isEmpty ? 'unknown' : busId,
      latitude: lat,
      longitude: lng,
    );
  }

  static double? _toDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim());
    return null;
  }
}

class ApiService {
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.245.253.38:8000',
  );

  ApiService({String? baseUrl}) : baseUrl = (baseUrl ?? _defaultBaseUrl).trim();

  final String baseUrl;

  double? _toNullableDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  Future<Map<String, dynamic>> _getJsonObject(Uri uri) async {
    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) {
        throw ApiException('Request failed (${res.statusCode}) for $uri');
      }

      final raw = jsonDecode(res.body);
      if (raw is! Map<String, dynamic>) {
        throw const ApiException('Invalid API response format');
      }

      return raw;
    } on TimeoutException {
      throw ApiException('Connection timeout to $uri');
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on FormatException {
      throw const ApiException('Server returned malformed JSON');
    }
  }

  // 🔹 Live Bus Location - calls GET /bus/1/eta
  Future<List<LiveBusLocation>> getBusLocations({int busId = 1}) async {
    try {
      final eta = await getBusEta(busId: busId);
      return <LiveBusLocation>[
        LiveBusLocation(
          busId: eta.busId.toString(),
          latitude: eta.latitude,
          longitude: eta.longitude,
        ),
      ];
    } catch (_) {
      return const <LiveBusLocation>[];
    }
  }

  Future<BusEta> getBusEta({int busId = 1}) async {
    try {
      final uri = Uri.parse('$baseUrl/bus/$busId/eta');
      final raw = await _getJsonObject(uri);

      final latitude = _toNullableDouble(raw['latitude']);
      final longitude = _toNullableDouble(raw['longitude']);

      print('API /bus/$busId/eta latitude: $latitude');
      print('API /bus/$busId/eta longitude: $longitude');

      if (latitude == null || longitude == null) {
        print('Invalid coordinates');
        throw const ApiException('Invalid coordinates from API');
      }

      final safeRaw = Map<String, dynamic>.from(raw)
        ..['latitude'] = latitude
        ..['longitude'] = longitude;

      return BusEta.fromJson(safeRaw);
    } catch (e) {
      print('API ERROR: $e');
      rethrow;
    }
  }

  // 🔥 REAL ROAD ROUTE (FIXED)
  Future<List<List<double>>> getRouteGeometry(List<BusStop> stops) async {
    if (stops.length < 2) return [];

    // 🔥 LIMIT to 25 points (Mapbox limit)
    final limitedStops = stops.length > 25 ? stops.sublist(0, 25) : stops;

    final coords =
        limitedStops.map((s) => "${s.longitude},${s.latitude}").join(';');

    final url = "https://api.mapbox.com/directions/v5/mapbox/driving/$coords"
        "?geometries=geojson&overview=full&access_token=YOUR_MAPBOX_TOKEN";

    print("URL: $url");

    final res = await http.get(Uri.parse(url));

    print("Status: ${res.statusCode}");

    if (res.statusCode != 200) return [];

    final data = jsonDecode(res.body);

    if (data['routes'] == null || data['routes'].isEmpty) {
      print("NO ROUTE FOUND");
      return [];
    }

    final geometry = data['routes'][0]['geometry']['coordinates'];

    print("ROUTE POINTS: ${geometry.length}");

    return (geometry as List)
        .map((point) => List<double>.from(point as List))
        .toList();
  }
}
