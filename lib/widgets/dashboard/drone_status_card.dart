import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/drone_provider.dart';

class DroneStatusCard extends StatelessWidget {
  const DroneStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (context, drone, _) {
        final ready = drone.gpsReady &&
            drone.isWsConnected &&
            drone.drone.connected;

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
                      ready ? 'READY TO FLY' : 'NOT READY',
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
                    _tile('Mode', drone.flightMode),
                    _tile('Altitude',
                        '${drone.altitude.toStringAsFixed(1)} m'),
                    _tile('Heading',
                        '${drone.heading.toStringAsFixed(0)}°'),
                    _tile('GPS',
                        drone.gpsReady ? 'READY' : 'SEARCHING'),
                    _tile('Satellites', drone.satellites.toString()),
                    _tile('Battery',
                        '${drone.battery.toStringAsFixed(0)}%'),
                    _tile('Pixhawk',
                        drone.drone.connected ? 'Connected' : 'Offline'),
                    _tile('Telemetry',
                        drone.isWsConnected ? 'Live' : 'Offline'),
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
