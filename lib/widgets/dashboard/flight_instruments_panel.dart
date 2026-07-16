import 'package:flutter/material.dart';

class FlightInstrumentsPanel extends StatelessWidget {
  final double verticalSpeed;
  final double groundSpeed;
  final double airSpeed;
  final double homeDistance;
  final Duration flightTime;
  final int signal;
  final double cpuTemp;
  final int raspberryLoad;

  const FlightInstrumentsPanel({
    super.key,
    required this.verticalSpeed,
    required this.groundSpeed,
    required this.airSpeed,
    required this.homeDistance,
    required this.flightTime,
    required this.signal,
    required this.cpuTemp,
    required this.raspberryLoad,
  });

  Widget rowItem(String t,String v)=>Padding(
    padding: const EdgeInsets.symmetric(vertical:4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:[Text(t),Text(v,style: const TextStyle(fontWeight: FontWeight.bold))],
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
            const Text('Flight Instruments',style:TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const Divider(),
            rowItem('Vertical Speed','${verticalSpeed.toStringAsFixed(1)} m/s'),
            rowItem('Ground Speed','${groundSpeed.toStringAsFixed(1)} m/s'),
            rowItem('Air Speed','${airSpeed.toStringAsFixed(1)} m/s'),
            rowItem('Home Distance','${homeDistance.toStringAsFixed(1)} m'),
            rowItem('Flight Time','${flightTime.inMinutes}m ${flightTime.inSeconds%60}s'),
            rowItem('Signal','$signal %'),
            rowItem('CPU Temp','${cpuTemp.toStringAsFixed(1)} °C'),
            rowItem('Pi Load','$raspberryLoad %'),
          ],
        ),
      ),
    );
  }
}


