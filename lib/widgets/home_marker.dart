import 'package:flutter/material.dart';

class HomeMarker extends StatelessWidget {

  const HomeMarker({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 42,

      height: 42,

      decoration: BoxDecoration(

        color: Colors.green,

        borderRadius: BorderRadius.circular(25),

      ),

      child: const Icon(

        Icons.home,

        color: Colors.white,

      ),

    );

  }

}
