import 'package:flutter/material.dart';

class DroneHUD extends StatelessWidget {
  final double roll;
  final double pitch;
  final double yaw;
  final double altitude;
  final double speed;

  const DroneHUD({
    super.key,
    required this.roll,
    required this.pitch,
    required this.yaw,
    required this.altitude,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 260,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flight, size: 56),
              Text('Roll : ${roll.toStringAsFixed(1)}°'),
              Text('Pitch: ${pitch.toStringAsFixed(1)}°'),
              Text('Yaw   : ${yaw.toStringAsFixed(1)}°'),
              const Divider(),
              Text('Altitude : ${altitude.toStringAsFixed(1)} m'),
              Text('Speed    : ${speed.toStringAsFixed(1)} m/s'),
            ],
          ),
        ),
      ),
    );
  }
}

 