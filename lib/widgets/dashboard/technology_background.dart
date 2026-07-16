import 'dart:math' as math;

import 'package:flutter/material.dart';

class TechnologyBackground extends CustomPaint {
  TechnologyBackground()
      : super(
          painter: _TechnologyBackgroundPainter(),
        );
}

class _TechnologyBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient: white to soft blue
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFAFBFC),
        const Color(0xFFE8F0FF),
        const Color(0xFFD4E3FF),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final bgPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw hexagonal patterns (left side)
    _drawHexagons(canvas, size);

    // Draw circuit traces (left and bottom)
    _drawCircuitTraces(canvas, size);

    // Draw neural network nodes (right side)
    _drawNeuralNetwork(canvas, size);

    // Draw wireframe drone (upper left)
    _drawWireframeDrone(canvas, size);

    // Draw glowing particles
    _drawParticles(canvas, size);

    // Draw world map with location pins (bottom)
    _drawWorldMap(canvas, size);

    // Draw VARUNA AI watermark (center)
    _drawWatermark(canvas, size);
  }

  void _drawHexagons(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final smallPaint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Scattered hexagons
    final hexagons = [
      (x: size.width * 0.05, y: size.height * 0.15, size: 40.0),
      (x: size.width * 0.12, y: size.height * 0.08, size: 50.0),
      (x: size.width * 0.08, y: size.height * 0.35, size: 35.0),
      (x: size.width * 0.15, y: size.height * 0.50, size: 45.0),
      (x: size.width * 0.95, y: size.height * 0.15, size: 60.0),
      (x: size.width * 0.92, y: size.height * 0.35, size: 50.0),
    ];

    for (final hex in hexagons) {
      _drawHexagon(
        canvas,
        Offset(hex.x, hex.y),
        hex.size,
        hex.size > 45 ? paint : smallPaint,
      );
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * 3.14159 / 180;
      final x = center.dx + size * 0.5 * math.cos(angle);
      final y = center.dy + size * 0.5 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawCircuitTraces(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.3)
      ..strokeWidth = 1;

    // Branching circuit traces (left side)
    canvas.drawLine(Offset(size.width * 0.08, size.height * 0.45),
        Offset(size.width * 0.18, size.height * 0.55), paint);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.55),
        Offset(size.width * 0.25, size.height * 0.50), paint);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.55),
        Offset(size.width * 0.20, size.height * 0.65), paint);

    // Connection points
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.45), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.55), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.50), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.65), 3, dotPaint);
  }

  void _drawNeuralNetwork(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerNodePaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.5)
      ..strokeWidth = 1;

    // Neural network cluster (right side)
    final nodes = [
      (x: size.width * 0.75, y: size.height * 0.10),
      (x: size.width * 0.85, y: size.height * 0.05),
      (x: size.width * 0.95, y: size.height * 0.15),
      (x: size.width * 0.92, y: size.height * 0.25),
      (x: size.width * 0.78, y: size.height * 0.20),
      (x: size.width * 0.88, y: size.height * 0.35),
      (x: size.width * 0.97, y: size.height * 0.30),
    ];

    // Draw connections
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if ((nodes[i].x - nodes[j].x).abs() < 150 &&
            (nodes[i].y - nodes[j].y).abs() < 200) {
          canvas.drawLine(
            Offset(nodes[i].x, nodes[i].y),
            Offset(nodes[j].x, nodes[j].y),
            linePaint,
          );
        }
      }
    }

    // Draw nodes
    for (final node in nodes) {
      canvas.drawCircle(Offset(node.x, node.y), 4, nodePaint);
      canvas.drawCircle(Offset(node.x, node.y), 2, centerNodePaint);
    }
  }

  void _drawWireframeDrone(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF64B5F6).withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final bodyCenter = Offset(size.width * 0.12, size.height * 0.18);

    // Simplified drone wireframe
    // Center body
    canvas.drawCircle(bodyCenter, 8, paint);

    // Arms
    canvas.drawLine(bodyCenter, bodyCenter + const Offset(-15, -8), paint);
    canvas.drawLine(bodyCenter, bodyCenter + const Offset(15, -8), paint);
    canvas.drawLine(bodyCenter, bodyCenter + const Offset(-15, 8), paint);
    canvas.drawLine(bodyCenter, bodyCenter + const Offset(15, 8), paint);

    // Rotors
    for (final offset in [
      const Offset(-15, -8),
      const Offset(15, -8),
      const Offset(-15, 8),
      const Offset(15, 8),
    ]) {
      canvas.drawCircle(bodyCenter + offset, 4, paint);
    }

    // Camera
    canvas.drawCircle(bodyCenter + const Offset(0, 12), 3, paint);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final particlePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 1;

    final particles = [
      (x: size.width * 0.20, y: size.height * 0.12),
      (x: size.width * 0.35, y: size.height * 0.18),
      (x: size.width * 0.60, y: size.height * 0.08),
      (x: size.width * 0.75, y: size.height * 0.12),
      (x: size.width * 0.88, y: size.height * 0.22),
      (x: size.width * 0.45, y: size.height * 0.45),
      (x: size.width * 0.65, y: size.height * 0.50),
      (x: size.width * 0.30, y: size.height * 0.65),
      (x: size.width * 0.85, y: size.height * 0.75),
    ];

    for (final particle in particles) {
      canvas.drawCircle(Offset(particle.x, particle.y), 1.5, particlePaint);
    }
  }

  void _drawWorldMap(Canvas canvas, Size size) {
    final mapPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.15)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.3)
      ..strokeWidth = 1;

    // Simplified world map grid at bottom
    const mapTop = 0.75;
    const mapHeight = 0.2;

    // Draw grid pattern for world map
    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 5; j++) {
        final x = size.width * (0.1 + i * 0.08);
        final y = size.height * (mapTop + j * 0.04);

        if (i % 2 == 0 && j % 2 == 0) {
          canvas.drawCircle(Offset(x, y), 0.5, dotPaint);
        }
      }
    }

    // Draw continents (simplified)
    final globePath = Path();
    globePath.moveTo(size.width * 0.20, size.height * 0.85);
    globePath.cubicTo(
      size.width * 0.30,
      size.height * 0.80,
      size.width * 0.40,
      size.height * 0.88,
      size.width * 0.50,
      size.height * 0.85,
    );
    globePath.cubicTo(
      size.width * 0.70,
      size.height * 0.82,
      size.width * 0.80,
      size.height * 0.88,
      size.width * 0.85,
      size.height * 0.90,
    );

    canvas.drawPath(globePath, mapPaint);

    // Location pins
    final pinPaint = Paint()
      ..color = const Color(0xFF42A5F5).withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pins = [
      Offset(size.width * 0.25, size.height * 0.80),
      Offset(size.width * 0.50, size.height * 0.83),
      Offset(size.width * 0.75, size.height * 0.82),
    ];

    for (final pin in pins) {
      canvas.drawCircle(pin, 5, pinPaint);
      canvas.drawCircle(pin, 2, pinPaint);
    }
  }

  void _drawWatermark(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'VARUNA\nAI',
        style: TextStyle(
          color: Color(0xFF5B7CCC),
          fontSize: 72,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width * 0.5 - textPainter.width * 0.5,
        size.height * 0.42 - textPainter.height * 0.5,
      ),
    );
  }

  @override
  bool shouldRepaint(_TechnologyBackgroundPainter oldDelegate) => false;
}
