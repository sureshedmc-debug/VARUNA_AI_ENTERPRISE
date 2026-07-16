import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/weather_model.dart';
import '../../providers/weather_provider.dart';
import '../../widgets/dashboard/glassmorphic_card.dart';
import '../../widgets/dashboard/weather_panel.dart';

class MissionScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MissionScreen({super.key, this.onBack});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  // ── Navigation ────────────────────────────────────────────────

  void _navigateBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/dashboard', (route) => false);
  }

  // ── Mission Planning actions ──────────────────────────────────

  void _onManualMissionPlanning() {
    // Set a representative planning area location so weather refreshes
    // for the selected area. Using device location as default here.
    final weatherProvider = context.read<WeatherProvider>();
    weatherProvider.refresh();
    _showInfoSnackbar('Manual Mission Planning – map coming soon.');
  }

  void _onAIMissionPlanning() {
    final weatherProvider = context.read<WeatherProvider>();
    weatherProvider.refresh();
    _showInfoSnackbar('AI Mission Planning – AI engine coming soon.');
  }

  Future<void> _onStartMission() async {
    final weatherProvider = context.read<WeatherProvider>();
    final weather = weatherProvider.weather;

    // Perform weather safety check before allowing start.
    final confirmed = await _showWeatherSafetyCheck(weather);
    if (confirmed && mounted) {
      _showInfoSnackbar('Mission started.');
    }
  }

  // ── Weather Safety Check Dialog ───────────────────────────────

  Future<bool> _showWeatherSafetyCheck(WeatherData? weather) async {
    if (weather == null) {
      return _showSimpleConfirmDialog(
        title: 'Start Mission',
        message: 'Weather data unavailable. Start mission anyway?',
      );
    }

    final safety = weather.flightSafety;
    final warnings = _buildWarnings(weather);

    if (safety == FlightSafetyStatus.safe && warnings.isEmpty) {
      // No issues – confirm immediately.
      return _showSimpleConfirmDialog(
        title: '🟢 Safe to Fly',
        message: 'Conditions are optimal. Start mission?',
      );
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _WeatherSafetyDialog(
        weather: weather,
        safety: safety,
        warnings: warnings,
      ),
    );
    return result ?? false;
  }

  Future<bool> _showSimpleConfirmDialog({
    required String title,
    required String message,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Start'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  List<String> _buildWarnings(WeatherData w) {
    final warnings = <String>[];
    if (w.windSpeed > 10) {
      warnings.add('⚠️ High Wind: ${w.windSpeed.toStringAsFixed(1)} m/s (limit 10 m/s)');
    }
    if (w.rainProbability > 50) {
      warnings.add('⚠️ Heavy Rain probability: ${w.rainProbability}% (limit 50%)');
    }
    if (w.visibility < 5) {
      warnings.add('⚠️ Poor Visibility: ${w.visibility.toStringAsFixed(1)} km (min 5 km)');
    }
    return warnings;
  }

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _navigateBack,
          tooltip: 'Back to Dashboard',
        ),
        title: const Text(
          'Mission Control',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _navigateToDashboard,
            tooltip: 'Dashboard',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Live Weather Card ──────────────────────────────
            const WeatherPanel(),
            const SizedBox(height: 24),

            // ── Mission Planning buttons ───────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _onManualMissionPlanning,
                    icon: const Icon(Icons.map),
                    label: const Text('Manual Mission Planning'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _onAIMissionPlanning,
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI Mission Planning'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Start Mission button ───────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onStartMission,
                icon: const Icon(Icons.flight_takeoff),
                label: const Text('Start Mission'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Active Missions ────────────────────────────────
            GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Missions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMissionTile(
                    'Area Mapping - Zone A',
                    'In Progress',
                    Colors.blue,
                    '65%',
                  ),
                  const SizedBox(height: 12),
                  _buildMissionTile(
                    'Waste Detection - Site B',
                    'Pending',
                    Colors.orange,
                    '0%',
                  ),
                  const SizedBox(height: 12),
                  _buildMissionTile(
                    'Environmental Survey - Site C',
                    'Completed',
                    Colors.green,
                    '100%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Mission Details ────────────────────────────────
            GlassmorphicCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mission Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Duration', '1h 45m'),
                  _buildDetailRow('Altitude', '50m'),
                  _buildDetailRow('Battery Usage', '78%'),
                  _buildDetailRow('Distance', '2.3 km'),
                  _buildDetailRow('Photos Captured', '234'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Mission tile ──────────────────────────────────────────────

  Widget _buildMissionTile(
    String title,
    String status,
    Color statusColor,
    String progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  border:
                      Border.all(color: statusColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value:
                        double.parse(progress.replaceAll('%', '')) / 100,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                progress,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Weather Safety Check Dialog ───────────────────────────────────

class _WeatherSafetyDialog extends StatelessWidget {
  final WeatherData weather;
  final FlightSafetyStatus safety;
  final List<String> warnings;

  const _WeatherSafetyDialog({
    required this.weather,
    required this.safety,
    required this.warnings,
  });

  @override
  Widget build(BuildContext context) {
    final Color headerColor;
    final String headerEmoji;
    final String headerLabel;

    switch (safety) {
      case FlightSafetyStatus.safe:
        headerColor = Colors.green;
        headerEmoji = '🟢';
        headerLabel = 'SAFE TO FLY';
      case FlightSafetyStatus.caution:
        headerColor = Colors.orange;
        headerEmoji = '🟡';
        headerLabel = 'FLY WITH CAUTION';
      case FlightSafetyStatus.unsafe:
        headerColor = Colors.red;
        headerEmoji = '🔴';
        headerLabel = 'DO NOT FLY';
    }

    return AlertDialog(
      title: Row(
        children: [
          Text(headerEmoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Weather Safety Check',
              style: TextStyle(fontWeight: FontWeight.bold, color: headerColor),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: headerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: headerColor.withOpacity(0.4)),
              ),
              child: Text(
                headerLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: headerColor,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Current conditions summary
            _conditionRow(
                Icons.thermostat,
                'Temperature',
                '${weather.temperature.toStringAsFixed(1)} °C'),
            _conditionRow(
                Icons.air,
                'Wind Speed',
                '${weather.windSpeed.toStringAsFixed(1)} m/s'),
            _conditionRow(
                Icons.visibility,
                'Visibility',
                '${weather.visibility.toStringAsFixed(1)} km'),
            _conditionRow(
                Icons.wb_cloudy,
                'Condition',
                weather.condition),

            // Warnings
            if (warnings.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Warnings',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              ...warnings.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(w, style: const TextStyle(fontSize: 13)),
                ),
              ),
              const SizedBox(height: 8),
              if (safety == FlightSafetyStatus.unsafe)
                const Text(
                  'Proceeding in these conditions may be dangerous. '
                  'The operator assumes full responsibility.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                safety == FlightSafetyStatus.unsafe ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(
            safety == FlightSafetyStatus.unsafe
                ? 'I Understand – Start Anyway'
                : 'Start Mission',
          ),
        ),
      ],
    );
  }

  Widget _conditionRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
