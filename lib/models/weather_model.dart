class WeatherModel {
  WeatherModel({
    required this.temperatureC,
    required this.condition,
    required this.iconCode,
    required this.windSpeed,
    required this.windDeg,
    required this.humidity,
    required this.visibilityKm,
    required this.locationName,
    required this.lastUpdated,
    required this.isRaining,
  });

  final double temperatureC;
  final String condition;
  final String iconCode;
  final double windSpeed;
  final int windDeg;
  final int humidity;
  final double visibilityKm;
  final String locationName;
  final DateTime lastUpdated;
  final bool isRaining;

  factory WeatherModel.fromOpenWeatherJson(Map<String, dynamic> json) {
    final weatherList = (json['weather'] as List<dynamic>?) ?? const [];
    final weather0 = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};

    final main = (json['main'] as Map<String, dynamic>?) ?? const {};
    final wind = (json['wind'] as Map<String, dynamic>?) ?? const {};

    final rain = json['rain'];
    final snow = json['snow'];

    return WeatherModel(
      temperatureC: (main['temp'] as num?)?.toDouble() ?? 0,
      condition: (weather0['main'] as String?) ?? 'Unknown',
      iconCode: (weather0['icon'] as String?) ?? '01d',
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0,
      windDeg: (wind['deg'] as num?)?.toInt() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      visibilityKm: ((json['visibility'] as num?)?.toDouble() ?? 0) / 1000,
      locationName: (json['name'] as String?) ?? 'Unknown Location',
      lastUpdated: DateTime.now(),
      isRaining: rain != null || snow != null,
    );
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  String get windDirection {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((windDeg % 360) / 22.5).round() % 16;
    return directions[index];
  }

  FlightStatus get flightStatus {
    final normalizedCondition = condition.toLowerCase();
    final hasSevereCondition = normalizedCondition.contains('thunderstorm') ||
        normalizedCondition.contains('tornado') ||
        normalizedCondition.contains('squall');

    if (hasSevereCondition || windSpeed > 12 || visibilityKm < 2 || isRaining) {
      return FlightStatus.doNotFly;
    }

    if (windSpeed > 8 || visibilityKm < 5 || normalizedCondition.contains('mist') ||
        normalizedCondition.contains('fog') ||
        normalizedCondition.contains('haze') ||
        normalizedCondition.contains('drizzle') ||
        normalizedCondition.contains('rain')) {
      return FlightStatus.caution;
    }

    return FlightStatus.safe;
  }
}

enum FlightStatus { safe, caution, doNotFly }
