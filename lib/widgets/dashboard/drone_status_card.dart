import 'package:flutter/material.dart';

import '../../services/network/connection_manager.dart';
import '../../services/telemetry/telemetry_service.dart';

class DroneStatusCard extends StatelessWidget {
  const DroneStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        ConnectionManager.instance,
        TelemetryService.instance,
      ]),
      builder: (context, _) {
        final telemetry = TelemetryService.instance;
        final connection = ConnectionManager.instance;

        final ready = telemetry.readyToFly &&
            connection.isPixhawkConnected &&
            connection.isTelemetryConnected;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      ready ? Icons.check_circle : Icons.error,
                      color: ready ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ready ? "READY TO FLY" : "NOT READY",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _tile("Mode", telemetry.flightMode),
                    _tile("Altitude",
                        "${telemetry.altitude.toStringAsFixed(1)} m"),
                    _tile("Heading",
                        "${telemetry.heading.toStringAsFixed(0)}°"),
                    _tile("GPS",
                        telemetry.gpsReady ? "READY" : "SEARCHING"),
                    _tile("Satellites",
                        telemetry.satellites.toString()),
                    _tile("Battery",
                        "${telemetry.battery.toStringAsFixed(0)}%"),
                    _tile("Pixhawk",
                        connection.isPixhawkConnected ? "Connected" : "Offline"),
                    _tile("Telemetry",
                        connection.isTelemetryConnected ? "Live" : "Offline"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tile(String title, String value) {
    return SizedBox(
      width: 150,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

