import 'package:flutter/material.dart';
import 'system_status_item.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: [
              SystemStatusItem(
                icon: Icons.memory,
                title: 'Raspberry Pi',
                isActive: false,
              ),
              const SizedBox(height: 16),
              SystemStatusItem(
                icon: Icons.flight,
                title: 'Pixhawk',
                isActive: false,
              ),
              const SizedBox(height: 16),
              SystemStatusItem(
                icon: Icons.location_on,
                title: 'GPS',
                isActive: false,
              ),
              const SizedBox(height: 16),
              SystemStatusItem(
                icon: Icons.videocam,
                title: 'Camera',
                isActive: false,
              ),
              const SizedBox(height: 16),
              SystemStatusItem(
                icon: Icons.psychology,
                title: 'AI Model',
                isActive: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
