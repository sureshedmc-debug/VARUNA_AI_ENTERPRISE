import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/waypoint_model.dart';
import '../../services/telemetry/telemetry_service.dart';
import '../../widgets/drone_marker.dart';
import '../../widgets/home_marker.dart';

class MissionMapWidget extends StatefulWidget {
  final List<WaypointModel> waypoints;
  final LatLng homePosition;

  const MissionMapWidget({
    super.key,
    required this.waypoints,
    required this.homePosition,
  });

  @override
  State<MissionMapWidget> createState() => _MissionMapWidgetState();
}

class _MissionMapWidgetState extends State<MissionMapWidget> {
  final MapController _mapController = MapController();
  double _zoom = 15.0;
  bool _followDrone = true;
  String _selectedLayer = 'Satellite';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TelemetryService.instance,
      builder: (context, _) {
        final telemetry = TelemetryService.instance;
        final hasDronePos = telemetry.latitude != 0 || telemetry.longitude != 0;
        final dronePosition = hasDronePos
            ? LatLng(telemetry.latitude, telemetry.longitude)
            : widget.homePosition;

        if (_followDrone && hasDronePos) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _mapController.move(dronePosition, _mapController.camera.zoom);
            }
          });
        }

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: hasDronePos
                      ? dronePosition
                      : widget.homePosition,
                  initialZoom: _zoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: _selectedLayer == 'Satellite'
                        ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.varuna.ai',
                  ),
                  if (widget.waypoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: widget.waypoints
                              .map(
                                (w) => LatLng(w.latitude, w.longitude),
                              )
                              .toList(),
                          strokeWidth: 3,
                          color: Colors.cyan,
                        ),
                      ],
                    ),
                  if (widget.waypoints.length >= 3)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: _geofencePoints(),
                          borderColor: Colors.orange,
                          borderStrokeWidth: 2,
                          color: Colors.orange.withOpacity(0.1),
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
                      ...widget.waypoints.map(
                        (w) => Marker(
                          point: LatLng(w.latitude, w.longitude),
                          width: 30,
                          height: 30,
                          child: _WaypointMarker(sequence: w.sequence),
                        ),
                      ),
                      if (hasDronePos)
                        Marker(
                          point: dronePosition,
                          width: 50,
                          height: 50,
                          child: Transform.rotate(
                            angle: telemetry.heading * math.pi / 180,
                            child: const DroneMarker(),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 16,
                right: 16,
                child: _CompassWidget(heading: telemetry.heading),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: _DirectionArrow(heading: telemetry.heading),
              ),
              Positioned(
                top: 64,
                left: 16,
                child: _MapInfoOverlay(telemetry: telemetry),
              ),
              Positioned(
                bottom: 80,
                right: 16,
                child: _ZoomControls(
                  onZoomIn: () {
                    _zoom = math.min(_zoom + 1, 20);
                    _mapController.move(
                      _mapController.camera.center,
                      _zoom,
                    );
                    if (mounted) setState(() {});
                  },
                  onZoomOut: () {
                    _zoom = math.max(_zoom - 1, 2);
                    _mapController.move(
                      _mapController.camera.center,
                      _zoom,
                    );
                    if (mounted) setState(() {});
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                right: 16,
                child: _LayerSelector(
                  selected: _selectedLayer,
                  onChanged: (layer) {
                    if (mounted) setState(() => _selectedLayer = layer);
                  },
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: FloatingActionButton.small(
                  heroTag: 'follow_drone_map',
                  backgroundColor: _followDrone
                      ? const Color(0xFF42A5F5)
                      : const Color(0xFF1E3A5F),
                  onPressed: () {
                    if (mounted) {
                      setState(() => _followDrone = !_followDrone);
                    }
                  },
                  child: Icon(
                    _followDrone ? Icons.gps_fixed : Icons.gps_not_fixed,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<LatLng> _geofencePoints() {
    if (widget.waypoints.isEmpty) return [];
    double minLat = widget.homePosition.latitude;
    double maxLat = widget.homePosition.latitude;
    double minLng = widget.homePosition.longitude;
    double maxLng = widget.homePosition.longitude;
    for (final w in widget.waypoints) {
      minLat = math.min(minLat, w.latitude);
      maxLat = math.max(maxLat, w.latitude);
      minLng = math.min(minLng, w.longitude);
      maxLng = math.max(maxLng, w.longitude);
    }
    const pad = 0.0003;
    return [
      LatLng(minLat - pad, minLng - pad),
      LatLng(maxLat + pad, minLng - pad),
      LatLng(maxLat + pad, maxLng + pad),
      LatLng(minLat - pad, maxLng + pad),
    ];
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _WaypointMarker extends StatelessWidget {
  final int sequence;

  const _WaypointMarker({required this.sequence});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepOrange,
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
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _CompassWidget extends StatelessWidget {
  final double heading;

  const _CompassWidget({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xCC0D1B2A),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF42A5F5), width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _NeedlePainter(),
            ),
          ),
          const Icon(Icons.circle, color: Colors.white, size: 5),
          Positioned(
            top: 5,
            child: Text(
              'N',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Positioned(
            bottom: 5,
            child: Text(
              'S',
              style: TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ),
          const Positioned(
            right: 5,
            child: Text(
              'E',
              style: TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ),
          const Positioned(
            left: 5,
            child: Text(
              'W',
              style: TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawPath(
      Path()
        ..moveTo(cx, cy - 18)
        ..lineTo(cx - 5, cy)
        ..lineTo(cx + 5, cy)
        ..close(),
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      Path()
        ..moveTo(cx, cy + 18)
        ..lineTo(cx - 5, cy)
        ..lineTo(cx + 5, cy)
        ..close(),
      Paint()
        ..color = Colors.white70
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DirectionArrow extends StatelessWidget {
  final double heading;

  const _DirectionArrow({required this.heading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xCC0D1B2A),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF42A5F5), width: 1),
      ),
      child: Transform.rotate(
        angle: heading * math.pi / 180,
        child: const Icon(
          Icons.navigation,
          color: Color(0xFF42A5F5),
          size: 22,
        ),
      ),
    );
  }
}

class _MapInfoOverlay extends StatelessWidget {
  final TelemetryService telemetry;

  const _MapInfoOverlay({required this.telemetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1B2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ALT: ${telemetry.altitude.toStringAsFixed(1)} m',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            'HDG: ${telemetry.heading.toStringAsFixed(0)}°',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          Text(
            'SPD: ${telemetry.speed.toStringAsFixed(1)} m/s',
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _ZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const _ZoomControls({required this.onZoomIn, required this.onZoomOut});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ZoomBtn(icon: Icons.add, onPressed: onZoomIn),
        const SizedBox(height: 4),
        _ZoomBtn(icon: Icons.remove, onPressed: onZoomOut),
      ],
    );
  }
}

class _ZoomBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ZoomBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xCC0D1B2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF42A5F5), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _LayerSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _LayerSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xCC0D1B2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF42A5F5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Satellite', 'Map'].map((layer) {
          final isSelected = selected == layer;
          return GestureDetector(
            onTap: () => onChanged(layer),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF42A5F5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                layer,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
