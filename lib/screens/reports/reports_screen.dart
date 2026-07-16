import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061B34),
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Icon(
          Icons.analytics,
          color: Colors.orange,
          size: 120,
        ),
      ),
    );
  }
}
