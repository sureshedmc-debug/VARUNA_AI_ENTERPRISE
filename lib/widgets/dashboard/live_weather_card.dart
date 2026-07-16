import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/weather_model.dart';
import '../../services/weather/weather_service.dart';

class LiveWeatherCard extends StatefulWidget {
  const LiveWeatherCard({super.key});

  @override
  State<LiveWeatherCard> createState() => _LiveWeatherCardState();
}

class _LiveWeatherCardState extends State<LiveWeatherCard> {
  final WeatherService _weatherService = WeatherService();

  WeatherModel? _weather;
  String? _error;
  bool _loading = true;
  bool _permissionDenied = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => _loadWeather());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _weatherService.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final permission = await _weatherService.ensureLocationPermission();
    if (permission == WeatherPermissionState.denied) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _loading = false;
      });
      return;
    }

    try {
      final weather = await _weatherService.fetchCurrentWeather();
      if (!mounted) return;
      setState(() {
        _permissionDenied = false;
        _weather = weather;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_permissionDenied) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Location Permission Required',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadWeather,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_loading && _weather == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _weather == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadWeather, child: const Text('Retry')),
          ],
        ),
      );
    }

    final weather = _weather;
    if (weather == null) return const SizedBox.shrink();

    final status = weather.flightStatus;
    final statusText = switch (status) {
      FlightStatus.safe => 'SAFE TO FLY',
      FlightStatus.caution => 'FLY WITH CAUTION',
      FlightStatus.doNotFly => 'DO NOT FLY',
    };

    final statusColor = switch (status) {
      FlightStatus.safe => Colors.green,
      FlightStatus.caution => Colors.orange,
      FlightStatus.doNotFly => Colors.red,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(weather.iconUrl, width: 48, height: 48),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperatureC.toStringAsFixed(1)}°C',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(weather.condition),
                  Text(weather.locationName),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            _fact('Wind', '${weather.windSpeed.toStringAsFixed(1)} m/s ${weather.windDirection}'),
            _fact('Humidity', '${weather.humidity}%'),
            _fact('Visibility', '${weather.visibilityKm.toStringAsFixed(1)} km'),
            _fact('Updated', DateFormat('hh:mm a').format(weather.lastUpdated)),
          ],
        ),
      ],
    );
  }

  Widget _fact(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 13),
        children: [
          TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
