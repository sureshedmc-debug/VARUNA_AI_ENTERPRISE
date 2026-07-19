import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/drone_provider.dart';

class DroneTelemetryCard extends StatelessWidget {
  const DroneTelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (context, drone, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.airplanemode_active,
                      color: Colors.blue.shade600, size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'Drone Telemetry',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTelemetryRow(
                  'Battery',
                  '${drone.battery.toStringAsFixed(0)}%',
                  drone.battery > 40 ? Colors.green : Colors.red),
              const SizedBox(height: 12),
              _buildTelemetryRow('Altitude',
                  '${drone.altitude.toStringAsFixed(1)} m', Colors.blue),
              const SizedBox(height: 12),
              _buildTelemetryRow('Ground Speed',
                  '${drone.speed.toStringAsFixed(1)} m/s', Colors.cyan),
              const SizedBox(height: 12),
              _buildTelemetryRow('Air Speed',
                  '${drone.airspeed.toStringAsFixed(1)} m/s', Colors.teal),
              const SizedBox(height: 12),
              _buildTelemetryRow(
                  'Heading',
                  '${drone.heading.toStringAsFixed(0)}°',
                  Colors.orange),
              const SizedBox(height: 12),
              _buildTelemetryRow(
                  'GPS',
                  '${drone.satellites} Satellites',
                  drone.gpsReady ? Colors.green : Colors.orange),
              const SizedBox(height: 12),
              _buildTelemetryRow(
                  'Flight Mode', drone.flightMode, Colors.purple),
              const SizedBox(height: 12),
              _buildTelemetryRow(
                  'Armed',
                  drone.isArmed ? 'Armed' : 'Disarmed',
                  drone.isArmed ? Colors.red : Colors.green),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTelemetryRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

