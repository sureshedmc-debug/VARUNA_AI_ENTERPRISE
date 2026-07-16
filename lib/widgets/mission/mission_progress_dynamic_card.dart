import 'package:flutter/material.dart';

class MissionProgressCard extends StatelessWidget {
  final int completedWaypoints;
  final int totalWaypoints;
  final String missionStatus;
  final String missionTime;
  final double remainingDistance;
  final double areaSurveyed;

  const MissionProgressCard({
    super.key,
    required this.completedWaypoints,
    required this.totalWaypoints,
    required this.missionStatus,
    required this.missionTime,
    required this.remainingDistance,
    required this.areaSurveyed,
  });

  double get missionProgress {
    if (totalWaypoints == 0) return 0.0;
    return (completedWaypoints / totalWaypoints) * 100;
  }

  Color _getProgressColor(double progress) {
    if (progress <= 25) return Colors.red;
    if (progress <= 50) return Colors.orange;
    if (progress <= 75) return Colors.blue;
    if (progress < 100) return Colors.lightGreen;
    return Colors.green;
  }

  bool get isMissionComplete => missionProgress >= 100;

  @override
  Widget build(BuildContext context) {
    final progressColor = _getProgressColor(missionProgress);

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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment_turned_in, color: progressColor, size: 28),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mission Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        missionStatus,
                        style: TextStyle(
                          fontSize: 12,
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${missionProgress.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Bar
          _buildProgressBar(progressColor),
          const SizedBox(height: 24),
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatTile('Completed Waypoints', '$completedWaypoints / $totalWaypoints', Colors.blue),
              _buildStatTile('Remaining Waypoints', '${totalWaypoints - completedWaypoints}', Colors.orange),
              _buildStatTile('Mission Time', missionTime, Colors.purple),
              _buildStatTile('Remaining Distance', '${remainingDistance.toStringAsFixed(1)} km', Colors.cyan),
              _buildStatTile('Area Surveyed', '${areaSurveyed.toStringAsFixed(1)} km²', Colors.green),
              _buildStatTile('Battery Status', 'Monitoring', Colors.amber),
            ],
          ),
          if (isMissionComplete) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Mission Completed Successfully',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '${missionProgress.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: missionProgress / 100,
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
