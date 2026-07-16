import 'package:flutter/material.dart';

class DroneMarker extends StatelessWidget {

  const DroneMarker({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 42,

      height: 42,

      decoration: BoxDecoration(

        color: Colors.red,

        borderRadius: BorderRadius.circular(25),

      ),

      child: const Icon(

        Icons.flight,

        color: Colors.white,

      ),

    );

  }

}