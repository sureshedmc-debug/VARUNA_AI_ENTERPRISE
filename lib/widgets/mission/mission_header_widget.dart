import 'package:flutter/material.dart';
import '../../services/mission/mission_service.dart';

class MissionHeaderWidget extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onDashboard;

  const MissionHeaderWidget({
    super.key,
    required this.onBack,
    required this.onDashboard,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MissionService.instance,
      builder: (context, _) {
        final mission = MissionService.instance;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _HeaderButton(
                icon: Icons.arrow_back,
                label: 'Back',
                onPressed: onBack,
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'VARUNA AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'MISSION CONTROL CENTER',
                    style: TextStyle(
                      color: Color(0xFF42A5F5),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _MissionStatusBadge(
                state: mission.state,
                missionName: mission.missionName,
              ),
              const SizedBox(width: 16),
              const _NotificationBadge(count: 3),
              const SizedBox(width: 8),
              _HeaderButton(
                icon: Icons.dashboard,
                label: 'Dashboard',
                onPressed: onDashboard,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white70, size: 18),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

class _MissionStatusBadge extends StatelessWidget {
  final MissionState state;
  final String missionName;

  const _MissionStatusBadge({
    required this.state,
    required this.missionName,
  });

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
        return 'MISSION RUNNING';
      case MissionState.paused:
        return 'MISSION PAUSED';
      case MissionState.rtl:
        return 'RETURNING HOME';
      case MissionState.completed:
        return 'MISSION COMPLETE';
      case MissionState.created:
        return 'MISSION READY';
      default:
        return 'STANDBY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = missionName.isNotEmpty
        ? ' · ${missionName.length > 15 ? '${missionName.substring(0, 15)}…' : missionName}'
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        border: Border.all(color: _color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$_label$name',
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  final int count;

  const _NotificationBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon:
              const Icon(Icons.notifications_outlined, color: Colors.white70),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        if (count > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
