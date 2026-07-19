import 'package:flutter/material.dart';

import '../../controllers/mission_controller.dart';
import '../../models/waypoint_model.dart';
import '../../services/mission/mission_service.dart';

class AiPlannerWidget extends StatefulWidget {
  final void Function(List<WaypointModel> waypoints, String missionName)
      onMissionGenerated;

  const AiPlannerWidget({super.key, required this.onMissionGenerated});

  @override
  State<AiPlannerWidget> createState() => _AiPlannerWidgetState();
}

class _AiPlannerWidgetState extends State<AiPlannerWidget> {
  final _objectiveController = TextEditingController();
  bool _isGenerating = false;
  _GeneratedMission? _generatedMission;
  bool _isExpanded = false;

  @override
  void dispose() {
    _objectiveController.dispose();
    super.dispose();
  }

  Future<void> _generateMission() async {
    if (_objectiveController.text.trim().isEmpty) return;
    if (mounted) {
      setState(() {
        _isGenerating = true;
        _generatedMission = null;
      });
    }
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final objective = _objectiveController.text.toLowerCase();
    final altitude = _suggestAltitude(objective);
    final speed = _suggestSpeed(objective);
    final waypoints = _buildSuggestedWaypoints(altitude, speed);

    setState(() {
      _isGenerating = false;
      _generatedMission = _GeneratedMission(
        waypoints: waypoints,
        altitude: altitude,
        speed: speed,
        estimatedTimeSec: (waypoints.length * 30).toInt(),
        estimatedBatteryPct: (waypoints.length * 5).clamp(10, 80),
        estimatedAreaSqM: waypoints.length * 250.0,
      );
    });
  }

  double _suggestAltitude(String objective) {
    if (objective.contains('survey') || objective.contains('map')) return 80;
    if (objective.contains('detect') || objective.contains('scan')) return 40;
    return 60;
  }

  double _suggestSpeed(String objective) {
    if (objective.contains('detail') || objective.contains('close')) return 3;
    if (objective.contains('fast') || objective.contains('quick')) return 10;
    return 6;
  }

  List<WaypointModel> _buildSuggestedWaypoints(
      double altitude, double speed) {
    return [
      WaypointModel(
          sequence: 1,
          latitude: 28.6150,
          longitude: 77.2080,
          altitude: altitude,
          speed: speed),
      WaypointModel(
          sequence: 2,
          latitude: 28.6160,
          longitude: 77.2090,
          altitude: altitude,
          speed: speed),
      WaypointModel(
          sequence: 3,
          latitude: 28.6170,
          longitude: 77.2080,
          altitude: altitude,
          speed: speed),
      WaypointModel(
          sequence: 4,
          latitude: 28.6180,
          longitude: 77.2090,
          altitude: altitude,
          speed: speed),
      WaypointModel(
          sequence: 5,
          latitude: 28.6190,
          longitude: 77.2080,
          altitude: altitude,
          speed: speed),
    ];
  }

  String _shortObjective() {
    final text = _objectiveController.text.trim();
    return text.length > 20 ? '${text.substring(0, 20)}…' : text;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A5F),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft:
                      _isExpanded ? Radius.zero : const Radius.circular(12),
                  bottomRight:
                      _isExpanded ? Radius.zero : const Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF42A5F5),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI MISSION PLANNER',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _objectiveController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText:
                          'e.g. "Survey Sector B and detect plastic waste"',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      fillColor: const Color(0xFF1E3A5F),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color(0xFF42A5F5),
                          width: 2,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.edit_note,
                        color: Color(0xFF42A5F5),
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generateMission,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 16),
                    label: Text(
                      _isGenerating
                          ? 'GENERATING MISSION…'
                          : 'GENERATE AI MISSION',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF42A5F5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                  if (_generatedMission != null) ...[
                    const SizedBox(height: 16),
                    _buildResult(_generatedMission!),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(_GeneratedMission mission) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              SizedBox(width: 6),
              Text(
                'MISSION GENERATED',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Row('Waypoints', '${mission.waypoints.length}', Icons.location_on),
          _Row(
            'Altitude',
            '${mission.altitude.toStringAsFixed(0)} m',
            Icons.height,
          ),
          _Row(
            'Speed',
            '${mission.speed.toStringAsFixed(0)} m/s',
            Icons.speed,
          ),
          _Row(
            'Est. Time',
            '${(mission.estimatedTimeSec / 60).toStringAsFixed(0)} min',
            Icons.timer,
          ),
          _Row(
            'Battery',
            '~${mission.estimatedBatteryPct}%',
            Icons.battery_4_bar,
          ),
          _Row(
            'Survey Area',
            '${(mission.estimatedAreaSqM / 1000).toStringAsFixed(2)} km²',
            Icons.map,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onMissionGenerated(
                      mission.waypoints,
                      'AI: ${_shortObjective()}',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.cyan,
                    side: const BorderSide(color: Colors.cyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'APPLY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onMissionGenerated(
                      mission.waypoints,
                      'AI: ${_shortObjective()}',
                    );
                    MissionService.instance.createMission(
                      name: 'AI: ${_shortObjective()}',
                      type: MissionType.aiGenerated,
                      waypointCount: mission.waypoints.length,
                    );
                    MissionController.instance.start();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'START',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GeneratedMission {
  final List<WaypointModel> waypoints;
  final double altitude;
  final double speed;
  final int estimatedTimeSec;
  final int estimatedBatteryPct;
  final double estimatedAreaSqM;

  const _GeneratedMission({
    required this.waypoints,
    required this.altitude,
    required this.speed,
    required this.estimatedTimeSec,
    required this.estimatedBatteryPct,
    required this.estimatedAreaSqM,
  });
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _Row(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade300, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
