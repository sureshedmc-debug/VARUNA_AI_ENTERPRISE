import 'package:flutter/material.dart';

class DroneTelemetryCard extends StatelessWidget {
  const DroneTelemetryCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              Icon(Icons.airplanemode_active, color: Colors.blue.shade600, size: 24),
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
          _buildTelemetryRow('Battery', '87%', Colors.green),
          const SizedBox(height: 12),
          _buildTelemetryRow('Altitude', '145.3 m', Colors.blue),
          const SizedBox(height: 12),
          _buildTelemetryRow('Speed', '12.5 m/s', Colors.cyan),
          const SizedBox(height: 12),
          _buildTelemetryRow('Heading', '127°', Colors.orange),
          const SizedBox(height: 12),
          _buildTelemetryRow('GPS', '12 Satellites', Colors.green),
          const SizedBox(height: 12),
          _buildTelemetryRow('Signal', 'Excellent', Colors.green),
          const SizedBox(height: 12),
          _buildTelemetryRow('Flight Time', '18m 45s', Colors.blue),
          const SizedBox(height: 12),
          _buildTelemetryRow('Flight Mode', 'Waypoint', Colors.purple),
        ],
      ),
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
