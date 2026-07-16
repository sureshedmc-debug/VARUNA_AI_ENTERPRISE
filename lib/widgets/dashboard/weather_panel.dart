import 'package:flutter/material.dart';

class WeatherPanel extends StatelessWidget {
  final double windSpeed;
  final String windDirection;
  final double temperature;
  final int humidity;
  final int rainProbability;
  final bool safeToFly;

  const WeatherPanel({
    super.key,
    required this.windSpeed,
    required this.windDirection,
    required this.temperature,
    required this.humidity,
    required this.rainProbability,
    required this.safeToFly,
  });

  Widget item(String title,String value)=>Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children:[
            Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),
            const SizedBox(height:8),
            Text(value),
          ],
        ),
      ),
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
            const Text('Weather & Flight Conditions',
              style: TextStyle(fontSize:18,fontWeight:FontWeight.bold)),
            const SizedBox(height:12),
            Row(children:[
              item('Wind','${windSpeed.toStringAsFixed(1)} m/s'),
              item('Direction',windDirection),
              item('Temp','${temperature.toStringAsFixed(1)} °C'),
            ]),
            Row(children:[
              item('Humidity','$humidity %'),
              item('Rain','$rainProbability %'),
              item('Status',safeToFly?'SAFE':'NOT SAFE'),
            ]),
          ],
        ),
      ),
    );
  }
}

