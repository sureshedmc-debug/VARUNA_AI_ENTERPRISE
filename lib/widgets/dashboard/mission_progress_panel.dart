import 'package:flutter/material.dart';

class MissionProgressPanel extends StatelessWidget {
  final double progress;
  final int currentWaypoint;
  final int totalWaypoints;
  final double distanceRemaining;
  final Duration eta;
  final int batteryRemaining;
  final int detections;
  final String status;

  const MissionProgressPanel({
    super.key,
    required this.progress,
    required this.currentWaypoint,
    required this.totalWaypoints,
    required this.distanceRemaining,
    required this.eta,
    required this.batteryRemaining,
    required this.detections,
    required this.status,
  });

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('Mission Progress',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            LinearProgressIndicator(value:progress),
            const SizedBox(height:12),
            Text('Waypoint: $currentWaypoint / $totalWaypoints'),
            Text('Distance Remaining: ${distanceRemaining.toStringAsFixed(1)} m'),
            Text('ETA: ${eta.inMinutes} min ${eta.inSeconds%60} sec'),
            Text('Battery Remaining: $batteryRemaining %'),
            Text('Objects Detected: $detections'),
            Text('Status: $status'),
          ],
        ),
      ),
    );
  }
}


