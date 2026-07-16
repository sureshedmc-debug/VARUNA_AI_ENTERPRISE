import 'package:flutter/material.dart';

class GPSInfoCard extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;

  const GPSInfoCard({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF102A43),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "LIVE GPS",
              style: TextStyle(
                color: Colors.cyan,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Latitude : ${latitude.toStringAsFixed(6)}",
              style: const TextStyle(color: Colors.white),
            ),

            Text(
              "Longitude : ${longitude.toStringAsFixed(6)}",
              style: const TextStyle(color: Colors.white),
            ),

            Text(
              "Speed : ${speed.toStringAsFixed(2)} m/s",
              style: const TextStyle(color: Colors.white),
            ),

            Text(
              "Accuracy : ${accuracy.toStringAsFixed(1)} m",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}