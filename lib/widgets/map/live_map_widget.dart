import 'package:flutter/material.dart';

import '../../services/telemetry/telemetry_service.dart';

class LiveMapWidget extends StatelessWidget {
  const LiveMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TelemetryService.instance,
      builder: (context, _) {
        final telemetry = TelemetryService.instance;

        return Card(
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.map),
                title: Text('Live Mission Map'),
                subtitle: Text(
                  'Home • Drone • Waypoints • Geofence',
                ),
              ),
              Container(
                height: 320,
                width: double.infinity,
                color: Colors.blueGrey.shade100,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map,size:64),
                    const SizedBox(height:16),
                    Text(
                      'Lat : ${telemetry.latitude.toStringAsFixed(6)}',
                    ),
                    Text(
                      'Lng : ${telemetry.longitude.toStringAsFixed(6)}',
                    ),
                    const SizedBox(height:16),
                    const Text(
                      'Google Maps / Flutter Map integration\nwill render here.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Chip(label: Text('🏠 Home')),
                    Chip(label: Text('🚁 Drone')),
                    Chip(label: Text('📍 Waypoints')),
                    Chip(label: Text('🛡 Geofence')),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

