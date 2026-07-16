import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_button, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            'Start Mission',
            Icons.play_arrow,
            Colors.green,
            () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Pause',
            Icons.pause,
            Colors.orange,
            () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Resume',
            Icons.play_arrow_outlined,
            Colors.blue,
            () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Return to Launch',
            Icons.home,
            Colors.purple,
            () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Land Now',
            Icons.landing_page,
            Colors.cyan,
            () {},
          ),
          const SizedBox(height: 10),
          _buildActionButton(
            'Emergency Stop',
            Icons.emergency,
            Colors.red,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}
