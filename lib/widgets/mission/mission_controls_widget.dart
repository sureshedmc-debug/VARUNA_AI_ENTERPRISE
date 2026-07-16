import 'package:flutter/material.dart';

import '../../controllers/mission_controller.dart';
import '../../services/mission/mission_service.dart';

class MissionControlsWidget extends StatelessWidget {
  final bool isArmed;
  final VoidCallback onArm;
  final VoidCallback onDisarm;

  const MissionControlsWidget({
    super.key,
    required this.isArmed,
    required this.onArm,
    required this.onDisarm,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MissionService.instance,
      builder: (context, _) {
        final mission = MissionService.instance;
        final isRunning = mission.state == MissionState.running;
        final isPaused = mission.state == MissionState.paused;
        final isActive = isRunning || isPaused;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(isArmed),
              const SizedBox(height: 12),
              // ARM / DISARM
              Row(
                children: [
                  Expanded(
                    child: _CtrlButton(
                      label: 'ARM',
                      icon: Icons.lock_open,
                      color: Colors.green,
                      onPressed: isArmed ? null : onArm,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CtrlButton(
                      label: 'DISARM',
                      icon: Icons.lock,
                      color: Colors.red.shade700,
                      onPressed: !isArmed ? null : onDisarm,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // START / PAUSE / RESUME
              Row(
                children: [
                  Expanded(
                    child: _CtrlButton(
                      label: 'START',
                      icon: Icons.play_arrow,
                      color: Colors.blue,
                      onPressed: !isRunning && isArmed
                          ? MissionController.instance.start
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CtrlButton(
                      label: 'PAUSE',
                      icon: Icons.pause,
                      color: Colors.orange,
                      onPressed:
                          isRunning ? MissionController.instance.pause : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CtrlButton(
                      label: 'RESUME',
                      icon: Icons.play_circle,
                      color: Colors.cyan,
                      onPressed:
                          isPaused ? MissionController.instance.resume : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // RTL / LAND
              Row(
                children: [
                  Expanded(
                    child: _CtrlButton(
                      label: 'RTL',
                      icon: Icons.home,
                      color: Colors.purple,
                      onPressed:
                          isActive ? MissionController.instance.rtl : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _CtrlButton(
                      label: 'LAND',
                      icon: Icons.flight_land,
                      color: Colors.teal,
                      onPressed: isArmed ? () {} : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _EmergencyButton(
                onPressed: () => MissionController.instance.rtl(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool armed) {
    return Row(
      children: [
        const Icon(Icons.gamepad, color: Color(0xFF42A5F5), size: 16),
        const SizedBox(width: 8),
        const Text(
          'MISSION CONTROLS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: armed
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            armed ? 'ARMED' : 'DISARMED',
            style: TextStyle(
              color: armed ? Colors.green : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Control button ───────────────────────────────────────────────────────────

class _CtrlButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _CtrlButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled
            ? color.withOpacity(0.15)
            : const Color(0xFF1E3A5F),
        foregroundColor: enabled ? color : Colors.grey.shade600,
        side: BorderSide(
          color: enabled ? color.withOpacity(0.4) : Colors.grey.shade800,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }
}

// ─── Emergency button ─────────────────────────────────────────────────────────

class _EmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmergencyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _confirm(context),
      icon: const Icon(Icons.emergency, size: 18),
      label: const Text(
        'EMERGENCY STOP',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.15),
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E3A5F),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text(
              'EMERGENCY STOP',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Immediately halt all motors?\nThis cannot be undone mid-flight.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'CONFIRM',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      onPressed();
    }
  }
}
