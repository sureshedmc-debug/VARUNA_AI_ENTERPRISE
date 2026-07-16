import 'package:flutter/material.dart';

class FlightControlPanel extends StatelessWidget {
  final VoidCallback onArm;
  final VoidCallback onDisarm;
  final VoidCallback onTakeoff;
  final VoidCallback onRTL;
  final VoidCallback onLand;
  final VoidCallback onEmergency;

  const FlightControlPanel({
    super.key,
    required this.onArm,
    required this.onDisarm,
    required this.onTakeoff,
    required this.onRTL,
    required this.onLand,
    required this.onEmergency,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing:12,
          runSpacing:12,
          children:[
            ElevatedButton.icon(onPressed:onArm,icon:const Icon(Icons.lock_open),label:const Text('ARM')),
            ElevatedButton.icon(onPressed:onDisarm,icon:const Icon(Icons.lock),label:const Text('DISARM')),
            ElevatedButton.icon(onPressed:onTakeoff,icon:const Icon(Icons.flight_takeoff),label:const Text('TAKEOFF')),
            ElevatedButton.icon(onPressed:onRTL,icon:const Icon(Icons.home),label:const Text('RTL')),
            ElevatedButton.icon(onPressed:onLand,icon:const Icon(Icons.flight_land),label:const Text('LAND')),
            FilledButton.icon(onPressed:onEmergency,icon:const Icon(Icons.warning),label:const Text('EMERGENCY STOP')),
          ],
        ),
      ),
    );
  }
}

 