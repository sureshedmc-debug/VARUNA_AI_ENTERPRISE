import 'package:flutter/material.dart';
import '../../widgets/dashboard/enterprise_header.dart';
import '../../widgets/dashboard/system_status_card.dart';
import '../../widgets/dashboard/preflight_checklist_card.dart';
import '../../widgets/dashboard/navigation_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final mainNavState =
        context.findAncestorStateOfType<_MainNavigationState>();

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
            const EnterpriseHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (isMobile)
                      _buildMobileLayout(context, mainNavState)
                    else
                      _buildDesktopLayout(context, mainNavState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    _MainNavigationState? mainNavState,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
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
        // Right Column
        Expanded(
          flex: 1,
          child: Column(
            children: [
              NavigationCard(
                title: 'Mission',
                subtitle: 'Plan & Execute Missions',
                icon: Icons.flight_takeoff,
                color: Colors.blue,
                onTap: () {
                  mainNavState?._onNavigate(1);
                },
              ),
              const SizedBox(height: 24),
              NavigationCard(
                title: 'Reports',
                subtitle: 'View Mission Reports',
                icon: Icons.assessment,
                color: Colors.orange,
                onTap: () {
                  mainNavState?._onNavigate(2);
                },
              ),
              const SizedBox(height: 24),
              NavigationCard(
                title: 'Settings',
                subtitle: 'System Configuration',
                icon: Icons.settings,
                color: Colors.purple,
                onTap: () {
                  mainNavState?._onNavigate(3);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    _MainNavigationState? mainNavState,
  ) {
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
          onTap: () {
            mainNavState?._onNavigate(1);
          },
        ),
        const SizedBox(height: 16),
        NavigationCard(
          title: 'Reports',
          subtitle: 'View Mission Reports',
          icon: Icons.assessment,
          color: Colors.orange,
          onTap: () {
            mainNavState?._onNavigate(2);
          },
        ),
        const SizedBox(height: 16),
        NavigationCard(
          title: 'Settings',
          subtitle: 'System Configuration',
          icon: Icons.settings,
          color: Colors.purple,
          onTap: () {
            mainNavState?._onNavigate(3);
          },
        ),
      ],
    );
  }
}

// Extension to access main navigation state
class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    MissionScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
    );
  }
}

// Placeholder screens
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox();
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox();
}
