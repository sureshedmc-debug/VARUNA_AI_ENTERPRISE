import 'package:flutter/material.dart';

class MissionSummaryCard extends StatelessWidget {
  final String missionType;
  final int waypoints;
  final double estimatedMinutes;
  final double estimatedArea;
  final int batteryRequired;
  final String aiModel;

  const MissionSummaryCard({
    super.key,
    required this.missionType,
    required this.waypoints,
    required this.estimatedMinutes,
    required this.estimatedArea,
    required this.batteryRequired,
    required this.aiModel,
  });

  Widget rowItem(String t,String v)=>Padding(
    padding: const EdgeInsets.symmetric(vertical:6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:[Text(t),Text(v,style:const TextStyle(fontWeight:FontWeight.bold))],
    ),
  );

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            const Text('Mission Summary',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const Divider(),
            rowItem('Mission',missionType),
            rowItem('Waypoints','$waypoints'),
            rowItem('Est. Flight','${estimatedMinutes.toStringAsFixed(1)} min'),
            rowItem('Area','${estimatedArea.toStringAsFixed(0)} m²'),
            rowItem('Battery','$batteryRequired %'),
            rowItem('AI Model',aiModel),
          ],
        ),
      ),
    );
  }
}

