import 'package:flutter/material.dart';

import 'modules/dashboard/dashboard_screen.dart';
import 'modules/mission/mission_screen.dart';
import 'modules/reports/reports_screen.dart';
import 'modules/settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardScreen(onNavigate: _onNavigate),
      const MissionScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];
  }

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
