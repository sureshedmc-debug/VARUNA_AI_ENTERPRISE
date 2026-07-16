import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class BatteryGauge extends StatelessWidget {
  final double battery;

  const BatteryGauge({
    super.key,
    required this.battery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF102A43),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              "BATTERY",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            CircularPercentIndicator(
              radius: 60,
              lineWidth: 10,
              percent: battery / 100,
              animation: true,
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: battery > 50
                  ? Colors.green
                  : battery > 20
                      ? Colors.orange
                      : Colors.red,
              center: Text(
                "${battery.toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}