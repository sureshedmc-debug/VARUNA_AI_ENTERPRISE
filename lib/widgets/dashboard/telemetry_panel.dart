import 'package:flutter/material.dart';

class TelemetryPanel extends StatelessWidget {
  final double altitude;
  final double speed;
  final double heading;
  final String flightMode;
  final double battery;
  final int satellites;

  const TelemetryPanel({
    super.key,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.flightMode,
    required this.battery,
    required this.satellites,
  });

  Widget tile(String t,String v)=>Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children:[
          Text(t,style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height:8),
          Text(v),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context){
    return GridView.count(
      shrinkWrap:true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount:3,
      childAspectRatio:2,
      children:[
        tile('Altitude','${altitude.toStringAsFixed(1)} m'),
        tile('Speed','${speed.toStringAsFixed(1)} m/s'),
        tile('Heading','${heading.toStringAsFixed(0)}°'),
        tile('Flight Mode',flightMode),
        tile('Battery','${battery.toStringAsFixed(0)} %'),
        tile('Satellites','$satellites'),
      ],
    );
  }
}

 