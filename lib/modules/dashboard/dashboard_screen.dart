import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEE, MMM d, yyyy');
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/dashboard_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
          color: const Color(0xFFF5F7FB),
        ),
        child: Column(
          children: [
            // Enterprise Header
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VARUNA AI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Waste Detection & Drone Intelligence',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile)
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              dateFormatter.format(now),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeFormatter.format(now),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.cloud,
                                  size: 16,
                                  color: Colors.blue.shade400,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  '22°C',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Partly Cloudy',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 24),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.cyan.shade400
                              ],
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
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: isMobile
                    ? _buildMobileLayout(context)
                    : _buildDesktopLayout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSystemStatusCard(),
              const SizedBox(height: 24),
              _buildPreflightChecklistCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildNavigationCard(
                title: 'Mission',
                subtitle: 'Plan & Execute Missions',
                icon: Icons.flight_takeoff,
                color: Colors.blue,
                onTap: () => onNavigate?.call(1),
              ),
              const SizedBox(height: 24),
              _buildNavigationCard(
                title: 'Reports',
                subtitle: 'View Mission Reports',
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
        const SizedBox(height: 24),
        _buildPreflightChecklistCard(),
        const SizedBox(height: 24),
        _buildNavigationCard(
          title: 'Mission',
          subtitle: 'Plan & Execute Missions',
          icon: Icons.flight_takeoff,
          color: Colors.blue,
          onTap: () => onNavigate?.call(1),
        ),
        const SizedBox(height: 16),
        _buildNavigationCard(
          title: 'Reports',
          subtitle: 'View Mission Reports',
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
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
          _buildStatusItem('Raspberry Pi', Icons.memory, false),
          const SizedBox(height: 16),
          _buildStatusItem('Pixhawk', Icons.flight, false),
          const SizedBox(height: 16),
          _buildStatusItem('GPS', Icons.location_on, false),
          const SizedBox(height: 16),
          _buildStatusItem('Camera', Icons.videocam, false),
          const SizedBox(height: 16),
          _buildStatusItem('AI Model', Icons.psychology, false),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, IconData icon, bool isActive) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.green.shade50 : Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.green.shade600 : Colors.red.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildPreflightChecklistCard() {
    final items = [
      'Raspberry Pi Connected',
      'Pixhawk Connected',
      'GPS Lock',
      'Compass Calibrated',
      'Camera Ready',
      'AI Model Loaded',
      'Battery Above 40%',
      'Mission Uploaded',
    ];

    final completedCount = items
        .where((item) => item == 'Battery Above 40%')
        .length;
    final progress = completedCount / items.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
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
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade100,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Ready',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}% Complete',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularPercentIndicator(
                    radius: 30,
                    lineWidth: 4,
                    percent: progress,
                    center: Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
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
        Container(
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
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(
              0,
              isHovered ? -8 : 0,
              0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered
                    ? color.withOpacity(0.3)
                    : Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? color.withOpacity(0.15)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: isHovered ? 20 : 12,
                  offset: Offset(0, isHovered ? 8 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: color.withOpacity(0.1),
                highlightColor: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 28,
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
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: color,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        );
      },
    );
  }
}
