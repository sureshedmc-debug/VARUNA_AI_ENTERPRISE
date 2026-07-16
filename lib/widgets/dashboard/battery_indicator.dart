import 'package:flutter/material.dart';
import '../../services/telemetry/telemetry_service.dart';

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TelemetryService.instance,
      builder: (context, _) {
        final battery = TelemetryService.instance.battery;

        Color color = Colors.green;
        if (battery < 30) {
          color = Colors.red;
        } else if (battery < 60) {
          color = Colors.orange;
        }

        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: battery / 100,
                strokeWidth: 10,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.battery_full,color: color,size: 32),
                  Text(
                    '${battery.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Battery'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

