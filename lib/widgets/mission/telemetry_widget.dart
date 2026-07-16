import 'package:flutter/material.dart';

import '../../services/telemetry/telemetry_service.dart';

class TelemetryWidget extends StatelessWidget {
  const TelemetryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TelemetryService.instance,
      builder: (context, _) {
        final t = TelemetryService.instance;
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _BatteryGauge(battery: t.battery),
                    const SizedBox(height: 12),
                    _buildGrid(t),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.sensors, color: Color(0xFF42A5F5), size: 16),
          const SizedBox(width: 8),
          const Text(
            'LIVE TELEMETRY',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(TelemetryService t) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _TelemetryTile(
          label: 'SPEED',
          value: t.speed.toStringAsFixed(1),
          unit: 'm/s',
          icon: Icons.speed,
          color: Colors.cyan,
        ),
        _TelemetryTile(
          label: 'ALTITUDE',
          value: t.altitude.toStringAsFixed(1),
          unit: 'm',
          icon: Icons.height,
          color: Colors.green,
        ),
        _TelemetryTile(
          label: 'VOLTAGE',
          value: '12.6',
          unit: 'V',
          icon: Icons.bolt,
          color: Colors.yellow,
        ),
        _TelemetryTile(
          label: 'LATITUDE',
          value: t.latitude.toStringAsFixed(4),
          unit: '°',
          icon: Icons.gps_fixed,
          color: Colors.blue,
        ),
        _TelemetryTile(
          label: 'LONGITUDE',
          value: t.longitude.toStringAsFixed(4),
          unit: '°',
          icon: Icons.gps_fixed,
          color: const Color(0xFF42A5F5),
        ),
        _TelemetryTile(
          label: 'SATELLITES',
          value: '${t.satellites}',
          unit: 'SAT',
          icon: Icons.satellite_alt,
          color: Colors.purple,
        ),
        _TelemetryTile(
          label: 'FLIGHT MODE',
          value: t.flightMode,
          unit: '',
          icon: Icons.flight,
          color: Colors.orange,
        ),
        _TelemetryTile(
          label: 'SIGNAL',
          value: t.readyToFly ? '100' : '0',
          unit: '%',
          icon: Icons.signal_cellular_alt,
          color: Colors.teal,
        ),
      ],
    );
  }
}

// ─── Battery gauge ────────────────────────────────────────────────────────────

class _BatteryGauge extends StatelessWidget {
  final double battery;

  const _BatteryGauge({required this.battery});

  Color get _color {
    if (battery > 50) return Colors.green;
    if (battery > 25) return Colors.orange;
    return Colors.red;
  }

  IconData get _icon {
    if (battery > 75) return Icons.battery_full;
    if (battery > 50) return Icons.battery_6_bar;
    if (battery > 25) return Icons.battery_4_bar;
    return Icons.battery_1_bar;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'BATTERY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '${battery.toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: _color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: battery / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFF0D1B2A),
                    valueColor: AlwaysStoppedAnimation<Color>(_color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Telemetry tile ───────────────────────────────────────────────────────────

class _TelemetryTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _TelemetryTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 102,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 12),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
