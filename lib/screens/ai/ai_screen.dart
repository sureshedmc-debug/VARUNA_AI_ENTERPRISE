import 'package:flutter/material.dart';

class AIScreen extends StatelessWidget {
  const AIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B34),
      appBar: AppBar(
        title: const Text("AI Detection"),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Icon(
          Icons.auto_awesome,
          color: Colors.deepPurple,
          size: 120,
        ),
      ),
    );
  }
}
