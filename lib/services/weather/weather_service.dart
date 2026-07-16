import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../models/weather_model.dart';

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiKey = String.fromEnvironment(
    'OPENWEATHER_API_KEY',
    defaultValue: '',
  );
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  final http.Client _client;

  Future<WeatherPermissionState> ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return WeatherPermissionState.denied;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return WeatherPermissionState.denied;
    }

    return WeatherPermissionState.granted;
  }

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
  }

  Future<WeatherModel> fetchCurrentWeather() async {
    if (_apiKey.isEmpty) {
      throw WeatherServiceException(
        'Missing OpenWeather API key. Set --dart-define=OPENWEATHER_API_KEY=YOUR_KEY',
      );
    }

    final position = await getCurrentPosition();
    final uri = Uri.parse(
      '$_baseUrl?lat=${position.latitude}&lon=${position.longitude}&appid=$_apiKey&units=metric',
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw WeatherServiceException('Failed to fetch weather: ${response.statusCode}');
    }

    final decoded = json.decode(response.body) as Map<String, dynamic>;
    try {
      return WeatherModel.fromOpenWeatherJson(decoded);
    } catch (e) {
      debugPrint('Weather parsing error: $e');
      throw WeatherServiceException('Unexpected weather response format.');
    }
  }

  void dispose() {
    _client.close();
  }
}

enum WeatherPermissionState { granted, denied }

class WeatherServiceException implements Exception {
  WeatherServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
