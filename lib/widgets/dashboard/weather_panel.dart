import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/weather_model.dart';
import '../../providers/weather_provider.dart';

/// Live weather card for the Dashboard and Mission Screen.
///
/// Displays real-time weather fetched from the device (or drone) location
/// with a colour-coded Flight Safety Status indicator.
class WeatherPanel extends StatelessWidget {
  const WeatherPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.weather == null) {
          return _buildLoadingCard();
        }
        if (provider.weather == null) {
          return _buildErrorCard(
            provider.error ?? 'No weather data.',
            onRetry: provider.refresh,
          );
        }
        return _buildWeatherCard(context, provider);
      },
    );
  }

  // ── Loading state ─────────────────────────────────────────────

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Fetching weather data…'),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────

  Widget _buildErrorCard(String message, {required VoidCallback onRetry}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main weather card ─────────────────────────────────────────

  Widget _buildWeatherCard(BuildContext context, WeatherProvider provider) {
    final w = provider.weather!;
    final safety = w.flightSafety;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────
            Row(
              children: [
                const Icon(Icons.cloud, color: Colors.blueAccent),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Weather & Flight Conditions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Refresh button
                IconButton(
                  onPressed: provider.isLoading ? null : provider.refresh,
                  icon: provider.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh, size: 20),
                  tooltip: 'Refresh',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // ── Location ─────────────────────────────────────────
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    w.locationName.isNotEmpty ? w.locationName : '—',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Updated ${_timeAgo(w.fetchedAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),

            const Divider(height: 24),

            // ── Weather data grid ────────────────────────────────
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _dataItem(
                  icon: Icons.thermostat,
                  label: 'Temperature',
                  value: '${w.temperature.toStringAsFixed(1)} °C',
                  color: Colors.orange,
                ),
                _dataItem(
                  icon: Icons.wb_cloudy,
                  label: 'Condition',
                  value: _capitalize(w.conditionDescription.isNotEmpty
                      ? w.conditionDescription
                      : w.condition),
                  color: Colors.blueGrey,
                ),
                _dataItem(
                  icon: Icons.air,
                  label: 'Wind Speed',
                  value: '${w.windSpeed.toStringAsFixed(1)} m/s',
                  color: Colors.cyan.shade700,
                ),
                _dataItem(
                  icon: Icons.explore,
                  label: 'Wind Direction',
                  value: w.windDirection,
                  color: Colors.teal,
                ),
                _dataItem(
                  icon: Icons.water_drop,
                  label: 'Humidity',
                  value: '${w.humidity} %',
                  color: Colors.blue,
                ),
                _dataItem(
                  icon: Icons.visibility,
                  label: 'Visibility',
                  value: '${w.visibility.toStringAsFixed(1)} km',
                  color: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Flight Safety Status ─────────────────────────────
            _buildSafetyBadge(safety, w),
          ],
        ),
      ),
    );
  }

  // ── Data item tile ────────────────────────────────────────────

  Widget _dataItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return SizedBox(
      width: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Flight Safety Badge ───────────────────────────────────────

  Widget _buildSafetyBadge(FlightSafetyStatus safety, WeatherData w) {
    final Color badgeColor;
    final String emoji;
    final String label;
    final String detail;

    switch (safety) {
      case FlightSafetyStatus.safe:
        badgeColor = Colors.green;
        emoji = '🟢';
        label = 'SAFE TO FLY';
        detail = 'Optimal conditions';
      case FlightSafetyStatus.caution:
        badgeColor = Colors.orange;
        emoji = '🟡';
        label = 'FLY WITH CAUTION';
        detail = _cautionDetail(w);
      case FlightSafetyStatus.unsafe:
        badgeColor = Colors.red;
        emoji = '🔴';
        label = 'DO NOT FLY';
        detail = _unsafeDetail(w);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        border: Border.all(color: badgeColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontSize: 12,
                    color: badgeColor.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper methods ────────────────────────────────────────────

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _cautionDetail(WeatherData w) {
    final reasons = <String>[];
    if (w.windSpeed >= 5 && w.windSpeed <= 10) {
      reasons.add('Moderate wind (${w.windSpeed.toStringAsFixed(1)} m/s)');
    }
    if (w.rainProbability >= 20 && w.rainProbability <= 50) {
      reasons.add('Rain probability ${w.rainProbability}%');
    }
    if (w.visibility >= 5 && w.visibility <= 10) {
      reasons.add('Reduced visibility (${w.visibility.toStringAsFixed(1)} km)');
    }
    return reasons.isEmpty ? 'Suboptimal but manageable' : reasons.join(' · ');
  }

  String _unsafeDetail(WeatherData w) {
    final reasons = <String>[];
    if (w.windSpeed > 10) {
      reasons.add('High wind (${w.windSpeed.toStringAsFixed(1)} m/s)');
    }
    if (w.rainProbability > 50) {
      reasons.add('Heavy rain risk (${w.rainProbability}%)');
    }
    if (w.visibility < 5) {
      reasons.add('Poor visibility (${w.visibility.toStringAsFixed(1)} km)');
    }
    if (w.weatherId >= 200 && w.weatherId < 300) {
      reasons.add('Thunderstorm');
    }
    return reasons.isEmpty ? 'Unsafe conditions' : reasons.join(' · ');
  }
}
