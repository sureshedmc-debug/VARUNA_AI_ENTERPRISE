import 'package:flutter/material.dart';

class SystemStatusItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;

  const SystemStatusItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.green.shade600 : Colors.red.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
