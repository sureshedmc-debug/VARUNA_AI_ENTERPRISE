import 'package:flutter/material.dart';

class SystemStatusBar extends StatelessWidget {
  final bool raspberryPi,pixhawk,gps,ai,camera;
  final int battery,satellites;

  const SystemStatusBar({
    super.key,
    required this.raspberryPi,
    required this.pixhawk,
    required this.gps,
    required this.ai,
    required this.camera,
    required this.battery,
    required this.satellites,
  });

  Widget status(String t,bool ok)=>Chip(
    avatar: Icon(Icons.circle,size:12,color:ok?Colors.green:Colors.red),
    label: Text(t),
  );

  @override
  Widget build(BuildContext context){
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing:8,
          runSpacing:8,
          children:[
            status('Raspberry Pi',raspberryPi),
            status('Pixhawk',pixhawk),
            status('GPS',gps),
            status('AI',ai),
            status('Camera',camera),
            Chip(label: Text('Battery: $battery%')),
            Chip(label: Text('Satellites: $satellites')),
          ],
        ),
      ),
    );
  }
}

 