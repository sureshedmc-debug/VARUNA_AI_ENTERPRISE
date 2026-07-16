import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'preflight_checklist_item.dart';

class PreflightChecklistCard extends StatelessWidget {
  const PreflightChecklistCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      'Raspberry Pi Connected',
      'Pixhawk Connected',
      'GPS Lock',
      'Compass Calibrated',
      'Camera Ready',
      'AI Model Loaded',
      'Battery Above 40%',
      'Mission Uploaded',
    ];

    final completedCount = items.where((item) {
      if (item == 'Battery Above 40%') return true;
      return false;
    }).length;

    final progress = completedCount / items.length;

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
            'Pre-Flight Checklist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            children: List.generate(
              items.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index < items.length - 1 ? 12 : 0,
                ),
                child: PreflightChecklistItem(
                  title: items[index],
                  isCompleted: completedCount > index,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade100,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Ready',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularPercentIndicator(
                    radius: 30,
                    lineWidth: 4,
                    percent: progress,
                    center: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    progressColor: Colors.blue.shade400,
                    backgroundColor: Colors.blue.shade100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
