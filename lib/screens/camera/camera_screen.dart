import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B34),
      appBar: AppBar(
        title: const Text("Camera"),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Icon(
          Icons.videocam,
          color: Colors.red,
          size: 120,
        ),
      ),
    );
  }
}
