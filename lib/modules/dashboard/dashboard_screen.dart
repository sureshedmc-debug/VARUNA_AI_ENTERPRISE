import 'package:flutter/material.dart';
import '../../widgets/dashboard/enterprise_header.dart';
import '../../widgets/dashboard/system_status_card.dart';
import '../../widgets/dashboard/preflight_checklist_card.dart';
import '../../widgets/dashboard/navigation_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/dashboard_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
          color: const Color(0xFFF5F7FB),
        ),
        child: Column(
          children: [
            const EnterpriseHeader(),
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
        Expanded(
          flex: 1,
          child: Column(
            children: [
              const SystemStatusCard(),
              const SizedBox(height: 24),
              const PreflightChecklistCard(),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              NavigationCard(
                title: 'Mission',
                subtitle: 'Plan & Execute Missions',
                icon: Icons.flight_takeoff,
                color: Colors.blue,
                onTap: () => onNavigate?.call(1),
              ),
              const SizedBox(height: 24),
              NavigationCard(
                title: 'Reports',
                subtitle: 'View Mission Reports',
                icon: Icons.assessment,
                color: Colors.orange,
                onTap: () => onNavigate?.call(2),
              ),
              const SizedBox(height: 24),
              NavigationCard(
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
        const SystemStatusCard(),
        const SizedBox(height: 24),
        const PreflightChecklistCard(),
        const SizedBox(height: 24),
        NavigationCard(
          title: 'Mission',
          subtitle: 'Plan & Execute Missions',
          icon: Icons.flight_takeoff,
          color: Colors.blue,
          onTap: () => onNavigate?.call(1),
        ),
        const SizedBox(height: 16),
        NavigationCard(
          title: 'Reports',
          subtitle: 'View Mission Reports',
          icon: Icons.assessment,
          color: Colors.orange,
          onTap: () => onNavigate?.call(2),
        ),
        const SizedBox(height: 16),
        NavigationCard(
          title: 'Settings',
          subtitle: 'System Configuration',
          icon: Icons.settings,
          color: Colors.purple,
          onTap: () => onNavigate?.call(3),
        ),
      ],
    );
  }
}
