import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/weather_model.dart';

/// Fetches live weather data from the OpenWeatherMap API.
///
/// Replace [apiKey] with a valid OpenWeatherMap API key.
/// A free-tier key can be obtained at https://openweathermap.org/api
class WeatherService {
  WeatherService._();
  static final WeatherService instance = WeatherService._();

  /// OpenWeatherMap API key. Replace with your own key.
  static const String apiKey = 'YOUR_OPENWEATHERMAP_API_KEY';

  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// Fetches current weather for [latitude] / [longitude].
  /// Returns `null` when the request fails or the key is not set.
  Future<WeatherData?> fetchWeather(double latitude, double longitude) async {
    if (apiKey == 'YOUR_OPENWEATHERMAP_API_KEY') {
      return _mockWeather(latitude, longitude);
    }

    try {
      final uri = Uri.parse(
        '$_baseUrl?lat=$latitude&lon=$longitude'
        '&appid=$apiKey&units=metric',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(json);
      }
    } catch (_) {
      // Network error – fall through and return null.
    }
    return null;
  }

  /// Returns realistic mock data so the UI works without an API key.
  WeatherData _mockWeather(double latitude, double longitude) {
    return WeatherData(
      temperature: 24.0,
      condition: 'Clear',
      conditionDescription: 'clear sky',
      weatherId: 800,
      windSpeed: 3.2,
      windDeg: 180,
      humidity: 58,
      visibility: 12.0,
      rainProbability: 5,
      latitude: latitude,
      longitude: longitude,
      locationName: '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}',
      fetchedAt: DateTime.now(),
    );
  }
}
