import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../widgets/dashboard/technology_background.dart';
import '../../widgets/dashboard/glassmorphic_card.dart';
import '../../widgets/dashboard/weather_panel.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;

    return Scaffold(
      body: Stack(
        children: [
          // Technology background
          SizedBox.expand(
            child: CustomPaint(
              painter: _TechnologyBackgroundPainter(),
              size: Size.infinite,
            ),
          ),
          // Content
          Column(
            children: [
              _buildPremiumHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
                  child: isMobile
                      ? _buildMobileLayout(context)
                      : _buildDesktopLayout(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEE, MMM d');
    final timeFormatter = DateFormat('HH:mm');
    final isMobile = MediaQuery.of(context).size.width < 768;

    return GlassmorphicCard(
      borderRadius: 0,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
      borderColor: Colors.white.withOpacity(0.15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VARUNA AI ENTERPRISE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1565C0),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'AI Autonomous Waste Detection Platform',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isMobile) ..._buildHeaderCenter(dateFormatter, timeFormatter),
          if (!isMobile) ..._buildHeaderRight(),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderCenter(DateFormat dateFormatter, DateFormat timeFormatter) {
    final now = DateTime.now();
    return [
      const SizedBox(width: 48),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dateFormatter.format(now),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            timeFormatter.format(now),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
      const SizedBox(width: 32),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(Icons.cloud, size: 14, color: Colors.blue.shade400),
              const SizedBox(width: 4),
              const Text(
                '22°C',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Partly Cloudy',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildHeaderRight() {
    return [
      const SizedBox(width: 32),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.15),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'System Online',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 24),
      _buildIconButton(Icons.notifications_none, Colors.grey.shade700),
      const SizedBox(width: 12),
      _buildIconButton(Icons.search, Colors.grey.shade700),
      const SizedBox(width: 12),
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.cyan.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'VA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      _buildIconButton(Icons.settings, Colors.grey.shade700),
    ];
  }

  Widget _buildIconButton(IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        splashColor: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSystemStatusCard(),
              const SizedBox(height: 24),
              _buildPreflightChecklistCard(),
              const SizedBox(height: 24),
              const WeatherPanel(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildNavigationCard(
                title: 'Mission',
                subtitle: 'Plan & Execute Operations',
                icon: Icons.flight_takeoff,
                color: Colors.blue,
                onTap: () => onNavigate?.call(1),
              ),
              const SizedBox(height: 24),
              _buildNavigationCard(
                title: 'Reports',
                subtitle: 'Analytics & Mission Data',
                icon: Icons.assessment,
                color: Colors.orange,
                onTap: () => onNavigate?.call(2),
              ),
              const SizedBox(height: 24),
              _buildNavigationCard(
                title: 'Settings',
                subtitle: 'System Configuration',
                icon: Icons.settings,
                color: Colors.purple,
                onTap: () => onNavigate?.call(3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildSystemStatusCard(),
        const SizedBox(height: 20),
        _buildPreflightChecklistCard(),
        const SizedBox(height: 20),
        const WeatherPanel(),
        const SizedBox(height: 20),
        _buildNavigationCard(
          title: 'Mission',
          subtitle: 'Plan & Execute Operations',
          icon: Icons.flight_takeoff,
          color: Colors.blue,
          onTap: () => onNavigate?.call(1),
        ),
        const SizedBox(height: 16),
        _buildNavigationCard(
          title: 'Reports',
          subtitle: 'Analytics & Mission Data',
          icon: Icons.assessment,
          color: Colors.orange,
          onTap: () => onNavigate?.call(2),
        ),
        const SizedBox(height: 16),
        _buildNavigationCard(
          title: 'Settings',
          subtitle: 'System Configuration',
          icon: Icons.settings,
          color: Colors.purple,
          onTap: () => onNavigate?.call(3),
        ),
      ],
    );
  }

  Widget _buildSystemStatusCard() {
    final items = [
      ('Raspberry Pi', Icons.memory, true),
      ('Pixhawk', Icons.flight, false),
      ('GPS', Icons.location_on, false),
      ('Camera', Icons.videocam, false),
      ('AI Engine', Icons.psychology, false),
      ('Telemetry', Icons.data_usage, true),
      ('Internet', Icons.cloud, true),
      ('Battery', Icons.battery_full, false),
    ];

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: items.map((item) {
              return _buildStatusTile(item.$2, item.$1, item.$3);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(IconData icon, String title, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isActive ? Colors.green : Colors.red).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.green.shade600 : Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreflightChecklistCard() {
    final items = [
      'Raspberry Pi Connected',
      'Pixhawk Connected',
      'GPS Lock',
      'Camera Ready',
      'Compass Calibrated',
      'AI Model Loaded',
      'Mission Uploaded',
      'Battery Above 40%',
    ];

    final completedCount = 1;
    final progress = completedCount / items.length;

    return GlassmorphicCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pre-Flight Checklist',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(
            items.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                bottom: index < items.length - 1 ? 12 : 0,
              ),
              child: _buildChecklistItem(
                items[index],
                completedCount > index,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mission Ready',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% System Ready',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularPercentIndicator(
                    radius: 35,
                    lineWidth: 5,
                    percent: progress,
                    center: Text(
                      '87%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    progressColor: Colors.blue.shade400,
                    backgroundColor: Colors.blue.shade100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String title, bool isCompleted) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? Colors.green.shade400 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          child: isCompleted
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isCompleted
                  ? Colors.green.shade600
                  : Colors.grey.shade600,
              decoration: isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transform: Matrix4.translationValues(0, isHovered ? -8 : 0, 0),
            child: GlassmorphicCard(
              borderColor: isHovered
                  ? color.withOpacity(0.4)
                  : Colors.white.withOpacity(0.2),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: color.withOpacity(0.15),
                  highlightColor: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.2),
                              color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.arrow_forward,
                            color: color,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey.shade300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Background painter (inlined for dashboard)
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

    _drawHexagons(canvas, size);
    _drawCircuitTraces(canvas, size);
    _drawNeuralNetwork(canvas, size);
    _drawWireframeDrone(canvas, size);
    _drawParticles(canvas, size);
    _drawWorldMap(canvas, size);
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
      final x = center.dx + size * 0.5 * (angle.cos());
      final y = center.dy + size * 0.5 * (angle.sin());
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

    canvas.drawLine(Offset(size.width * 0.08, size.height * 0.45),
        Offset(size.width * 0.18, size.height * 0.55), paint);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.55),
        Offset(size.width * 0.25, size.height * 0.50), paint);
    canvas.drawLine(Offset(size.width * 0.18, size.height * 0.55),
        Offset(size.width * 0.20, size.height * 0.65), paint);

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

    final nodes = [
      (x: size.width * 0.75, y: size.height * 0.10),
      (x: size.width * 0.85, y: size.height * 0.05),
      (x: size.width * 0.95, y: size.height * 0.15),
      (x: size.width * 0.92, y: size.height * 0.25),
      (x: size.width * 0.78, y: size.height * 0.20),
      (x: size.width * 0.88, y: size.height * 0.35),
      (x: size.width * 0.97, y: size.height * 0.30),
    ];

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

    canvas.drawCircle(bodyCenter, 8, paint);

    canvas.drawLine(bodyCenter, bodyCenter + const Offset(-15, -8), paint);
    canvas.drawLine(bodyCenter, bodyCenter + const Offset(15, -8), paint);
    canvas.drawLine(bodyCenter, bodyCenter + const Offset(-15, 8), paint);
    canvas.drawLine(bodyCenter, bodyCenter + const Offset(15, 8), paint);

    for (final offset in [
      const Offset(-15, -8),
      const Offset(15, -8),
      const Offset(-15, 8),
      const Offset(15, 8),
    ]) {
      canvas.drawCircle(bodyCenter + offset, 4, paint);
    }

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

    const mapTop = 0.75;
    const mapHeight = 0.2;

    for (int i = 0; i < 10; i++) {
      for (int j = 0; j < 5; j++) {
        final x = size.width * (0.1 + i * 0.08);
        final y = size.height * (mapTop + j * 0.04);

        if (i % 2 == 0 && j % 2 == 0) {
          canvas.drawCircle(Offset(x, y), 0.5, dotPaint);
        }
      }
    }

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
