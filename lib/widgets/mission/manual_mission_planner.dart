import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/mission_controller.dart';
import '../../models/waypoint_model.dart';
import '../../services/mission/mission_service.dart';
import '../../widgets/home_marker.dart';

class ManualMissionPlanner extends StatefulWidget {
  final LatLng homePosition;
  final void Function(
    List<WaypointModel> waypoints,
    String missionName,
    double altitude,
    double speed,
  ) onSave;

  const ManualMissionPlanner({
    super.key,
    required this.homePosition,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required LatLng homePosition,
    required void Function(
      List<WaypointModel>,
      String,
      double,
      double,
    ) onSave,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ManualMissionPlanner(
        homePosition: homePosition,
        onSave: onSave,
      ),
    );
  }

  @override
  State<ManualMissionPlanner> createState() => _ManualMissionPlannerState();
}

class _ManualMissionPlannerState extends State<ManualMissionPlanner> {
  final MapController _mapController = MapController();
  final _nameController = TextEditingController(text: 'Mission 1');

  final List<WaypointModel> _waypoints = [];
  final List<LatLng> _geofencePoints = [];
  bool _drawingGeofence = false;
  int? _selectedIndex;

  double _altitude = 60;
  double _speed = 6;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _addWaypoint(LatLng point) {
    setState(() {
      _waypoints.add(
        WaypointModel(
          sequence: _waypoints.length + 1,
          latitude: point.latitude,
          longitude: point.longitude,
          altitude: _altitude,
          speed: _speed,
        ),
      );
    });
  }

  void _deleteWaypoint(int index) {
    setState(() {
      _waypoints.removeAt(index);
      for (int i = 0; i < _waypoints.length; i++) {
        _waypoints[i] = _waypoints[i].copyWith(sequence: i + 1);
      }
      _selectedIndex = null;
    });
  }

  double get _distanceMeters {
    if (_waypoints.length < 2) return 0;
    const dist = Distance();
    double total = 0;
    for (int i = 0; i < _waypoints.length - 1; i++) {
      total += dist.as(
        LengthUnit.Meter,
        LatLng(_waypoints[i].latitude, _waypoints[i].longitude),
        LatLng(_waypoints[i + 1].latitude, _waypoints[i + 1].longitude),
      );
    }
    return total;
  }

  double get _flightTimeSec => _speed > 0 ? _distanceMeters / _speed : 0;
  double get _batteryPct =>
      (_flightTimeSec / 600 * 80).clamp(0.0, 80.0);

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: size.width,
        height: size.height * 0.92,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  Expanded(flex: 3, child: _buildMap()),
                  SizedBox(width: 280, child: _buildSidePanel()),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.route, color: Color(0xFF42A5F5), size: 20),
          const SizedBox(width: 10),
          const Text(
            'MANUAL MISSION PLANNER',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Text(
            _drawingGeofence
                ? 'Click map to draw geofence boundary'
                : 'Click map to add waypoints',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.homePosition,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, point) {
                if (_drawingGeofence) {
                  setState(() => _geofencePoints.add(point));
                } else {
                  _addWaypoint(point);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.varuna.ai',
              ),
              if (_waypoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _waypoints
                          .map((w) => LatLng(w.latitude, w.longitude))
                          .toList(),
                      strokeWidth: 3,
                      color: Colors.cyan,
                    ),
                  ],
                ),
              if (_geofencePoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _geofencePoints,
                      borderColor: Colors.orange,
                      borderStrokeWidth: 2,
                      color: Colors.orange.withOpacity(0.15),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.homePosition,
                    width: 40,
                    height: 40,
                    child: const HomeMarker(),
                  ),
                  ..._waypoints.asMap().entries.map((e) {
                    final idx = e.key;
                    final w = e.value;
                    return Marker(
                      point: LatLng(w.latitude, w.longitude),
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedIndex =
                              _selectedIndex == idx ? null : idx;
                        }),
                        child: _WpMarker(
                          sequence: w.sequence,
                          isSelected: _selectedIndex == idx,
                        ),
                      ),
                    );
                  }),
                  ..._geofencePoints.map(
                    (p) => Marker(
                      point: p,
                      width: 18,
                      height: 18,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_drawingGeofence && _geofencePoints.isNotEmpty)
            Positioned(
              top: 12,
              right: 12,
              child: ElevatedButton.icon(
                onPressed: () => setState(() => _geofencePoints.removeLast()),
                icon: const Icon(Icons.undo, size: 14),
                label: const Text(
                  'Undo',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xCC0D1B2A),
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1520),
        border: Border(
          left: BorderSide(color: Color(0xFF1E3A5F), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mission name
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel('MISSION NAME'),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    fillColor: const Color(0xFF1E3A5F),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E3A5F), height: 1),
          // Altitude
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionLabel('ALTITUDE'),
                    Text(
                      '${_altitude.toStringAsFixed(0)} m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _ThemedSlider(
                  value: _altitude,
                  min: 0,
                  max: 300,
                  divisions: 30,
                  color: const Color(0xFF42A5F5),
                  onChanged: (v) => setState(() => _altitude = v),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E3A5F), height: 1),
          // Speed
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionLabel('SPEED'),
                    Text(
                      '${_speed.toStringAsFixed(1)} m/s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _ThemedSlider(
                  value: _speed,
                  min: 1,
                  max: 15,
                  divisions: 14,
                  color: Colors.cyan,
                  onChanged: (v) => setState(() => _speed = v),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1E3A5F), height: 1),
          // Waypoint list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionLabel('WAYPOINTS (${_waypoints.length})'),
                Row(
                  children: [
                    _PillButton(
                      label: 'GEOFENCE',
                      active: _drawingGeofence,
                      color: Colors.orange,
                      onTap: () => setState(
                        () => _drawingGeofence = !_drawingGeofence,
                      ),
                    ),
                    if (_waypoints.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      _PillButton(
                        label: 'CLEAR',
                        active: false,
                        color: Colors.red,
                        onTap: () => setState(() => _waypoints.clear()),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Waypoint list
          Expanded(
            child: _waypoints.isEmpty
                ? Center(
                    child: Text(
                      'Tap the map to\nadd waypoints',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _waypoints.length,
                    itemBuilder: (_, i) => _WaypointListTile(
                      waypoint: _waypoints[i],
                      isSelected: _selectedIndex == i,
                      onTap: () => setState(() {
                        _selectedIndex = _selectedIndex == i ? null : i;
                      }),
                      onDelete: () => _deleteWaypoint(i),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          _StatChip(
            label: 'Distance',
            value: '${(_distanceMeters / 1000).toStringAsFixed(2)} km',
            icon: Icons.straighten,
            color: Colors.cyan,
          ),
          const SizedBox(width: 16),
          _StatChip(
            label: 'Flight Time',
            value: '${(_flightTimeSec / 60).toStringAsFixed(0)} min',
            icon: Icons.timer,
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          _StatChip(
            label: 'Battery',
            value: '~${_batteryPct.toStringAsFixed(0)}%',
            icon: Icons.battery_4_bar,
            color: Colors.orange,
          ),
          const SizedBox(width: 16),
          _StatChip(
            label: 'Waypoints',
            value: '${_waypoints.length}',
            icon: Icons.location_on,
            color: Colors.purple,
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _waypoints.isEmpty
                ? null
                : () {
                    _saveMission();
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.save, size: 16),
            label: const Text(
              'SAVE MISSION',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF42A5F5),
              side: const BorderSide(color: Color(0xFF42A5F5)),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _waypoints.isEmpty
                ? null
                : () {
                    _saveMission();
                    MissionController.instance.start();
                    Navigator.pop(context);
                  },
            icon: const Icon(Icons.play_arrow, size: 16),
            label: const Text(
              'START MISSION',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  void _saveMission() {
    widget.onSave(
      List.unmodifiable(_waypoints),
      _nameController.text,
      _altitude,
      _speed,
    );
    MissionService.instance.createMission(
      name: _nameController.text,
      type: MissionType.manual,
      waypointCount: _waypoints.length,
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _WpMarker extends StatelessWidget {
  final int sequence;
  final bool isSelected;

  const _WpMarker({required this.sequence, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.cyan : Colors.deepOrange,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$sequence',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _WaypointListTile extends StatelessWidget {
  final WaypointModel waypoint;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _WaypointListTile({
    required this.waypoint,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.cyan.withOpacity(0.1)
              : const Color(0xFF1E3A5F),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? Colors.cyan : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.deepOrange,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${waypoint.sequence}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${waypoint.latitude.toStringAsFixed(4)}, ${waypoint.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Alt: ${waypoint.altitude.toStringAsFixed(0)} m',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 16,
              ),
              onPressed: onDelete,
              constraints:
                  const BoxConstraints(minWidth: 28, minHeight: 28),
              padding: EdgeInsets.zero,
              tooltip: 'Delete waypoint',
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF42A5F5),
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _ThemedSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Color color;
  final ValueChanged<double> onChanged;

  const _ThemedSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: color,
        inactiveTrackColor: const Color(0xFF1E3A5F),
        thumbColor: color,
        overlayColor: color.withOpacity(0.2),
        trackHeight: 4,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: active ? color : const Color(0xFF1E3A5F),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? color : Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
