import 'package:flutter/material.dart';

import '../../services/mission/mission_service.dart';

class MissionProgressWidget extends StatelessWidget {
  final int completedWaypoints;
  final int totalWaypoints;

  const MissionProgressWidget({
    super.key,
    required this.completedWaypoints,
    required this.totalWaypoints,
  });

  double get _progress {
    if (totalWaypoints == 0) return 0.0;
    return (completedWaypoints / totalWaypoints).clamp(0.0, 1.0);
  }

  double get _percentage => _progress * 100;

  Color get _progressColor {
    if (_percentage <= 25) return Colors.red;
    if (_percentage <= 50) return Colors.orange;
    if (_percentage <= 75) return Colors.blue;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MissionService.instance,
      builder: (context, _) {
        final mission = MissionService.instance;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.timeline,
                    color: Color(0xFF42A5F5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'MISSION PROGRESS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _progressColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFF1E3A5F),
                  valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Waypoints: $completedWaypoints / $totalWaypoints',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  _StateBadge(state: mission.state),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StateBadge extends StatelessWidget {
  final MissionState state;

  const _StateBadge({required this.state});

  Color get _color {
    switch (state) {
      case MissionState.running:
        return Colors.green;
      case MissionState.paused:
        return Colors.orange;
      case MissionState.rtl:
        return Colors.deepOrange;
      case MissionState.completed:
        return Colors.blue;
      case MissionState.created:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }

  String get _label {
    switch (state) {
      case MissionState.running:
        return 'RUNNING';
      case MissionState.paused:
        return 'PAUSED';
      case MissionState.rtl:
        return 'RTL';
      case MissionState.completed:
        return 'COMPLETED';
      case MissionState.created:
        return 'READY';
      default:
        return 'IDLE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
