import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../models/detection_model.dart';
import '../../models/waypoint_model.dart';
import '../../services/mission/mission_service.dart';
import '../../services/telemetry/telemetry_service.dart';
import '../../widgets/mission/ai_planner_widget.dart';
import '../../widgets/mission/camera_feed_widget.dart';
import '../../widgets/mission/detection_list_widget.dart';
import '../../widgets/mission/manual_mission_planner.dart';
import '../../widgets/mission/mission_controls_widget.dart';
import '../../widgets/mission/mission_header_widget.dart';
import '../../widgets/mission/mission_map_widget.dart';
import '../../widgets/mission/mission_progress_widget.dart';
import '../../widgets/mission/telemetry_widget.dart';

class MissionScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const MissionScreen({super.key, this.onBack});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  bool _isArmed = false;
  int _completedWaypoints = 0;
  List<WaypointModel> _waypoints = [];
  final List<DetectionModel> _detections = [];

  LatLng get _homePosition {
    final t = TelemetryService.instance;
    if (t.latitude != 0 || t.longitude != 0) {
      return LatLng(t.latitude, t.longitude);
    }
    return const LatLng(28.6139, 77.2090);
  }

  void _onBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onDashboard() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (route) => false);
    }
  }

  void _arm() => setState(() => _isArmed = true);
  void _disarm() {
    setState(() {
      _isArmed = false;
    });
    MissionService.instance.resetMission();
  }

  void _onMissionGenerated(
      List<WaypointModel> waypoints, String missionName) {
    setState(() {
      _waypoints = waypoints;
      _completedWaypoints = 0;
    });
    MissionService.instance.createMission(
      name: missionName,
      type: MissionType.aiGenerated,
      waypointCount: waypoints.length,
    );
  }

  void _openManualPlanner() {
    ManualMissionPlanner.show(
      context,
      homePosition: _homePosition,
      onSave: (waypoints, name, altitude, speed) {
        setState(() {
          _waypoints = waypoints;
          _completedWaypoints = 0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06111E),
      body: Column(
        children: [
          MissionHeaderWidget(onBack: _onBack, onDashboard: _onDashboard),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return _buildDesktopLayout();
                }
                return _buildMobileLayout();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop layout ─────────────────────────────────────────────────────────

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Left panel 40% ───────────────────────────────────────────────────
        Flexible(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Camera feed (fixed height)
                SizedBox(
                  height: 280,
                  child: const CameraFeedWidget(),
                ),
                const SizedBox(height: 8),
                // Detections list (expanded)
                Expanded(
                  child: DetectionListWidget(detections: _detections),
                ),
                const SizedBox(height: 8),
                // Mission controls
                MissionControlsWidget(
                  isArmed: _isArmed,
                  onArm: _arm,
                  onDisarm: _disarm,
                ),
              ],
            ),
          ),
        ),
        // ── Right panel 60% ──────────────────────────────────────────────────
        Flexible(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
            child: Column(
              children: [
                // Map (expanded)
                Expanded(
                  child: MissionMapWidget(
                    waypoints: _waypoints,
                    homePosition: _homePosition,
                  ),
                ),
                const SizedBox(height: 8),
                // Bottom row: telemetry + progress + planning
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Telemetry
                      const Expanded(flex: 5, child: TelemetryWidget()),
                      const SizedBox(width: 8),
                      // Right column: progress + planning
                      Expanded(
                        flex: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MissionProgressWidget(
                              completedWaypoints: _completedWaypoints,
                              totalWaypoints: _waypoints.length,
                            ),
                            const SizedBox(height: 8),
                            AiPlannerWidget(
                              onMissionGenerated: _onMissionGenerated,
                            ),
                            const SizedBox(height: 8),
                            _ManualPlannerButton(
                              onPressed: _openManualPlanner,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(height: 240, child: const CameraFeedWidget()),
          const SizedBox(height: 8),
          SizedBox(
            height: 320,
            child: MissionMapWidget(
              waypoints: _waypoints,
              homePosition: _homePosition,
            ),
          ),
          const SizedBox(height: 8),
          MissionProgressWidget(
            completedWaypoints: _completedWaypoints,
            totalWaypoints: _waypoints.length,
          ),
          const SizedBox(height: 8),
          MissionControlsWidget(
            isArmed: _isArmed,
            onArm: _arm,
            onDisarm: _disarm,
          ),
          const SizedBox(height: 8),
          const TelemetryWidget(),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: DetectionListWidget(detections: _detections),
          ),
          const SizedBox(height: 8),
          AiPlannerWidget(onMissionGenerated: _onMissionGenerated),
          const SizedBox(height: 8),
          _ManualPlannerButton(onPressed: _openManualPlanner),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Manual planner button ────────────────────────────────────────────────────

class _ManualPlannerButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ManualPlannerButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.map, size: 16),
        label: const Text(
          'MANUAL MISSION PLANNING',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: const Color(0xFF42A5F5),
          side: const BorderSide(color: Color(0xFF42A5F5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
