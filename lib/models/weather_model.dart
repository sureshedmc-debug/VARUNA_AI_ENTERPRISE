/// Flight safety status based on weather conditions.
enum FlightSafetyStatus { safe, caution, unsafe }

/// Holds live weather data fetched from the OpenWeatherMap API.
class WeatherData {
  final double temperature;
  final String condition;
  final String conditionDescription;
  final int weatherId;
  final double windSpeed;
  final int windDeg;
  final int humidity;

  /// Visibility in kilometres.
  final double visibility;

  /// Rain probability derived from [weatherId] (0–100).
  final int rainProbability;

  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime fetchedAt;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.conditionDescription,
    required this.weatherId,
    required this.windSpeed,
    required this.windDeg,
    required this.humidity,
    required this.visibility,
    required this.rainProbability,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.fetchedAt,
  });

  // ──────────────────────────────────────────────────────────────
  // Computed helpers
  // ──────────────────────────────────────────────────────────────

  /// Converts wind degrees to a cardinal direction string.
  String get windDirection {
    const directions = [
      'N', 'NNE', 'NE', 'ENE',
      'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW',
      'W', 'WNW', 'NW', 'NNW',
    ];
    final index = ((windDeg % 360) / 22.5).round() % 16;
    return directions[index];
  }

  /// Determines individual flight safety for wind speed.
  FlightSafetyStatus get _windSafety {
    if (windSpeed < 5) return FlightSafetyStatus.safe;
    if (windSpeed <= 10) return FlightSafetyStatus.caution;
    return FlightSafetyStatus.unsafe;
  }

  /// Determines individual flight safety for rain probability.
  FlightSafetyStatus get _rainSafety {
    if (rainProbability < 20) return FlightSafetyStatus.safe;
    if (rainProbability <= 50) return FlightSafetyStatus.caution;
    return FlightSafetyStatus.unsafe;
  }

  /// Determines individual flight safety for visibility.
  FlightSafetyStatus get _visibilitySafety {
    if (visibility > 10) return FlightSafetyStatus.safe;
    if (visibility >= 5) return FlightSafetyStatus.caution;
    return FlightSafetyStatus.unsafe;
  }

  /// Determines individual flight safety based on weather condition ID.
  FlightSafetyStatus get _conditionSafety {
    // Thunderstorm (2xx) or heavy/freezing rain (502, 503, 504, 511, 531)
    if (weatherId >= 200 && weatherId < 300) return FlightSafetyStatus.unsafe;
    if (weatherId == 502 ||
        weatherId == 503 ||
        weatherId == 504 ||
        weatherId == 511 ||
        weatherId == 531) return FlightSafetyStatus.unsafe;

    // Light/moderate rain or drizzle (3xx, 5xx)
    if ((weatherId >= 300 && weatherId < 400) ||
        (weatherId >= 500 && weatherId < 600)) {
      return FlightSafetyStatus.caution;
    }

    // Snow (6xx) or atmosphere (fog/mist 7xx)
    if ((weatherId >= 600 && weatherId < 800)) {
      return FlightSafetyStatus.caution;
    }

    // Broken/overcast clouds (803, 804)
    if (weatherId == 803 || weatherId == 804) {
      return FlightSafetyStatus.caution;
    }

    // Clear / few / scattered clouds (800-802)
    return FlightSafetyStatus.safe;
  }

  /// Overall flight safety — the worst individual status wins.
  FlightSafetyStatus get flightSafety {
    final statuses = [_windSafety, _rainSafety, _visibilitySafety, _conditionSafety];
    if (statuses.contains(FlightSafetyStatus.unsafe)) {
      return FlightSafetyStatus.unsafe;
    }
    if (statuses.contains(FlightSafetyStatus.caution)) {
      return FlightSafetyStatus.caution;
    }
    return FlightSafetyStatus.safe;
  }

  /// Infers rain probability from OpenWeatherMap weather ID.
  static int rainProbabilityFromId(int id) {
    if (id >= 200 && id < 300) return 90; // thunderstorm
    if (id >= 300 && id < 400) return 60; // drizzle
    if (id >= 502 && id <= 531) return 90; // heavy/shower rain
    if (id >= 500 && id < 502) return 75; // moderate rain
    if (id >= 600 && id < 700) return 70; // snow
    if (id >= 700 && id < 800) return 50; // atmosphere
    if (id == 800) return 5;              // clear
    if (id == 801) return 10;             // few clouds
    if (id == 802) return 20;             // scattered clouds
    if (id == 803) return 35;             // broken clouds
    if (id == 804) return 45;             // overcast clouds
    return 0;
  }

  /// Parses a [WeatherData] from the OpenWeatherMap current-weather JSON.
  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List<dynamic>;
    final weatherInfo = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};
    final id = (weatherInfo['id'] as num?)?.toInt() ?? 800;

    final visibilityMetres = (json['visibility'] as num?)?.toDouble() ?? 10000;

    return WeatherData(
      temperature: (main['temp'] as num?)?.toDouble() ?? 0,
      condition: (weatherInfo['main'] as String?) ?? 'Unknown',
      conditionDescription: (weatherInfo['description'] as String?) ?? '',
      weatherId: id,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      windDeg: (wind['deg'] as num?)?.toInt() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      visibility: visibilityMetres / 1000.0,
      rainProbability: rainProbabilityFromId(id),
      latitude: (json['coord']?['lat'] as num?)?.toDouble() ?? 0,
      longitude: (json['coord']?['lon'] as num?)?.toDouble() ?? 0,
      locationName: (json['name'] as String?) ?? '',
      fetchedAt: DateTime.now(),
    );
  }
}
