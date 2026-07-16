import 'package:flutter/material.dart';

import 'screens/dashboard/dashboard_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/ai/ai_screen.dart';
import 'screens/reports/reports_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int _selectedIndex = 0;

  final List<Widget> _pages = const [

    DashboardScreen(),

    MapScreen(),

    CameraScreen(),

    AIScreen(),

    ReportsScreen(),

  ];

  void _onItemTapped(int index) {

    setState(() {

      _selectedIndex = index;

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: _pages[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: _selectedIndex,

        onTap: _onItemTapped,

        type: BottomNavigationBarType.fixed,

        backgroundColor: const Color(0xFF102A43),

        selectedItemColor: Colors.cyan,

        unselectedItemColor: Colors.grey,

        selectedFontSize: 12,

        unselectedFontSize: 11,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Map",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: "Camera",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: "AI",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Reports",
          ),

        ],

      ),

    );

  }

}