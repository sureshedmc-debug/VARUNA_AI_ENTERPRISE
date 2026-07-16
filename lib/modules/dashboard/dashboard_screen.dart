import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;

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
            _buildPremiumHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallMobile ? 16 : 24),
                child: isMobile
                    ? _buildMobileLayout()
                    : _buildDesktopLayout(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    final now = DateTime.now();
    final dateFormatter = DateFormat('EEE, MMM d');
    final timeFormatter = DateFormat('HH:mm');
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 16,
      ),
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
                    color: Colors.grey.shade600,
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
              color: Colors.grey.shade600,
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
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
          color: Colors.green.shade50,
          border: Border.all(color: Colors.green.shade200),
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

  Widget _buildDesktopLayout() {
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

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSystemStatusCard(),
        const SizedBox(height: 20),
        _buildPreflightChecklistCard(),
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.shade200 : Colors.red.shade200,
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
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
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.blue.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200, width: 1),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered
                    ? color.withOpacity(0.4)
                    : Colors.grey.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isHovered
                      ? color.withOpacity(0.2)
                      : Colors.black.withOpacity(0.06),
                  blurRadius: isHovered ? 24 : 16,
                  offset: Offset(0, isHovered ? 12 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                splashColor: color.withOpacity(0.15),
                highlightColor: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withOpacity(0.15),
                              color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withOpacity(0.2),
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
                          color: Colors.grey.shade600,
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
                              color: Colors.grey.shade200,
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
                              color: Colors.grey.shade200,
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
