import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class DroneMapWidget extends StatefulWidget {
  const DroneMapWidget({super.key});

  @override
  State<DroneMapWidget> createState() => _DroneMapWidgetState();
}

class _DroneMapWidgetState extends State<DroneMapWidget> {
  double _zoomLevel = 1.0;
  bool _isFullscreen = false;
  String _selectedLayer = 'Satellite';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map Background
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomPaint(
            painter: _MapPainter(zoomLevel: _zoomLevel),
            size: Size.infinite,
          ),
        ),
        // Zoom Controls
        Positioned(
          right: 16,
          top: 16,
          child: Column(
            children: [
              _buildZoomButton(Icons.add, () {
                setState(() => _zoomLevel = (_zoomLevel + 0.1).clamp(0.5, 3.0));
              }),
              const SizedBox(height: 8),
              _buildZoomButton(Icons.remove, () {
                setState(() => _zoomLevel = (_zoomLevel - 0.1).clamp(0.5, 3.0));
              }),
            ],
          ),
        ),
        // Fullscreen Button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            onPressed: () => setState(() => _isFullscreen = !_isFullscreen),
            backgroundColor: Colors.blue.shade600,
            child: Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
            ),
          ),
        ),
        // Layer Selector
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButton<String>(
              value: _selectedLayer,
              underline: const SizedBox(),
              items: ['Satellite', 'Terrain', 'Hybrid']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedLayer = value ?? 'Satellite');
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: Colors.blue.shade600,
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double zoomLevel;

  _MapPainter({required this.zoomLevel});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    final gridSpacing = 50.0 * zoomLevel;
    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += gridSpacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    // Draw mission path
    final pathPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2 * zoomLevel
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    path.lineTo(size.width * 0.7, size.height * 0.7);
    path.lineTo(size.width * 0.3, size.height * 0.7);
    path.close();
    canvas.drawPath(path, pathPaint);

    // Draw waypoints
    final waypointPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    final waypoints = [
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.3, size.height * 0.7),
    ];

    for (final waypoint in waypoints) {
      canvas.drawCircle(waypoint, 8 * zoomLevel, waypointPaint);
    }

    // Draw home marker
    final homePaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final homeOffset = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(homeOffset, 10 * zoomLevel, homePaint);
    canvas.drawCircle(
      homeOffset,
      15 * zoomLevel,
      Paint()
        ..color = Colors.green.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Draw drone marker
    final dronePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final droneOffset = Offset(size.width * 0.35, size.height * 0.35);
    canvas.drawCircle(droneOffset, 8 * zoomLevel, dronePaint);

    // Draw geofence
    final geofencePaint = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.8,
        height: size.height * 0.8,
      ),
      geofencePaint,
    );
  }

  @override
  bool shouldRepaint(_MapPainter oldDelegate) {
    return oldDelegate.zoomLevel != zoomLevel;
  }
}
