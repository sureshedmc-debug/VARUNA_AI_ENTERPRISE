import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../providers/drone_provider.dart';
import 'preflight_checklist_item.dart';

class PreflightChecklistCard extends StatelessWidget {
  const PreflightChecklistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DroneProvider>(
      builder: (context, drone, _) {
        final checks = <(String, bool)>[
          ('Raspberry Pi Connected', drone.isWsConnected),
          ('Pixhawk Connected', drone.drone.connected),
          ('GPS Lock', drone.gpsReady),
          ('Compass Calibrated', drone.drone.connected),
          ('Camera Ready', drone.isWsConnected),
          ('AI Model Loaded', drone.drone.connected),
          ('Battery Above 40%', drone.battery > 40),
          ('Mission Uploaded', false),
        ];

        final completedCount = checks.where((c) => c.$2).length;
        final progress =
            completedCount / checks.length;

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
                  checks.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < checks.length - 1 ? 12 : 0,
                    ),
                    child: PreflightChecklistItem(
                      title: checks[index].$1,
                      isCompleted: checks[index].$2,
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
      },
    );
  }
}


