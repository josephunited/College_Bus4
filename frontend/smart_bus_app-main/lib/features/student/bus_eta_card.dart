import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/api_service.dart';

class BusEtaCard extends StatefulWidget {
  const BusEtaCard({super.key, this.busId = 1});

  final int busId;

  @override
  State<BusEtaCard> createState() => _BusEtaCardState();
}

class _BusEtaCardState extends State<BusEtaCard> {
  final ApiService _apiService = ApiService();
  Timer? _timer;
  BusEta? _eta;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchETA();
    _startAutoRefresh();
  }

  @override
  void didUpdateWidget(covariant BusEtaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.busId != widget.busId) {
      _timer?.cancel();
      _timer = null;
      _eta = null;
      _error = null;
      _isLoading = true;
      fetchETA();
      _startAutoRefresh();
    }
  }

  void _startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      fetchETA();
    });
  }

  Future<void> fetchETA() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.getBusEta(busId: widget.busId);
      if (!mounted) return;
      setState(() {
        _eta = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _retry() => fetchETA();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _eta == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              SizedBox(width: 12),
              Text('Loading ETA...'),
            ],
          ),
        ),
      );
    }

    if (_error != null && _eta == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unable to load bus ETA',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(_error!, style: const TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final eta = _eta;
    if (eta == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live ETA',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _InfoRow(label: 'Next Stop', value: eta.nextStop),
            _InfoRow(
              label: 'ETA',
              value: '${eta.etaMinutes.toStringAsFixed(2)} mins',
            ),
            _InfoRow(
              label: 'Distance',
              value: '${eta.distanceKm.toStringAsFixed(2)} km',
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last refresh issue: $_error',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
