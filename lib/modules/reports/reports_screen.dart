import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mission Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.description),
              title: const Text('No Reports Available'),
              subtitle: const Text(
                'Mission reports will be generated automatically after landing.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

