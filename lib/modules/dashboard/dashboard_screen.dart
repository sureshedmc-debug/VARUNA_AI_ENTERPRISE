import 'package:flutter/material.dart';

import '../../widgets/dashboard/system_status_bar.dart';
import '../../widgets/dashboard/pre_flight_checklist.dart';
import '../../widgets/dashboard/camera_panel.dart';
import '../../widgets/dashboard/map_panel.dart';
import '../../widgets/dashboard/telemetry_panel.dart';
import '../../widgets/dashboard/mission_progress_panel.dart';
import '../../widgets/dashboard/ai_detection_panel.dart';
import '../../widgets/dashboard/weather_panel.dart';
import '../../widgets/dashboard/mission_timeline_panel.dart';
import '../../widgets/dashboard/drone_hud.dart';
import '../../widgets/dashboard/flight_instruments_panel.dart';

import '../../widgets/video/live_video_widget.dart';
import '../../widgets/map/live_map_widget.dart';

import '../../widgets/mission/mission_controls.dart';
import '../../widgets/mission/mission_summary_card.dart';
import '../../widgets/mission/flight_control_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "VARUNA AI Enterprise",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 8,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.08,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              _buildHeaderCard(),
              const SizedBox(height: 24),

              // Main Content: Left and Right Layout
              ResponsiveDashboardLayout(
                // LEFT PANEL: System Status + Pre-flight Checklist
                left: Column(
                  children: [
                    _buildSectionCard(
                      title: "System Status",
                      child: const SystemStatusBar(
                        raspberryPi: false,
                        pixhawk: false,
                        gps: false,
                        ai: false,
                        camera: false,
                        battery: 100,
                        satellites: 0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: "Pre-Flight Checklist",
                      child: const PreFlightChecklist(
                        checks: {
                          "Raspberry Pi": false,
                          "Pixhawk": false,
                          "GPS Lock": false,
                          "Camera Ready": false,
                          "AI Loaded": false,
                          "Battery > 40%": true,
                        },
                      ),
                    ),
                  ],
                ),

                // RIGHT PANEL: Mission, Reports, Settings
                right: Column(
                  children: [
                    _buildSectionCard(
                      title: "Mission",
                      child: Column(
                        children: [
                          const MissionControls(),
                          const SizedBox(height: 16),
                          const MissionProgressPanel(
                            progress: 0,
                            currentWaypoint: 0,
                            totalWaypoints: 0,
                            distanceRemaining: 0,
                            eta: Duration.zero,
                            batteryRemaining: 100,
                            detections: 0,
                            status: "WAITING",
                          ),
                          const SizedBox(height: 16),
                          const MissionSummaryCard(
                            missionType: "None",
                            waypoints: 0,
                            estimatedMinutes: 0,
                            estimatedArea: 0,
                            batteryRequired: 0,
                            aiModel: "YOLO",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: "Reports & Analytics",
                      child: Column(
                        children: [
                          AIDetectionPanel(
                            detections: const {},
                            confidence: 0,
                            lastDetection: "None",
                            lastTime: "--:--",
                            onExportCsv: () {},
                            onExportImages: () {},
                            onGenerateReport: () {},
                          ),
                          const SizedBox(height: 16),
                          const MissionTimelinePanel(
                            currentStep: 0,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: "Settings",
                      child: _buildSettingsPanel(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Full-Width Sections
              _buildSectionCard(
                title: "Flight Control",
                child: FlightControlPanel(
                  onArm: () {},
                  onDisarm: () {},
                  onTakeoff: () {},
                  onRTL: () {},
                  onLand: () {},
                  onEmergency: () {},
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                title: "Live Camera Feed",
                child: CameraPanel(
                  videoWidget: const LiveVideoWidget(),
                  recording: false,
                  resolution: "1080P",
                  fps: 30,
                  onSnapshot: () {},
                  onToggleOverlay: () {},
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                title: "Telemetry",
                child: Column(
                  children: [
                    const TelemetryPanel(
                      altitude: 0,
                      speed: 0,
                      heading: 0,
                      flightMode: "WAITING",
                      battery: 100,
                      satellites: 0,
                    ),
                    const SizedBox(height: 16),
                    const FlightInstrumentsPanel(
                      verticalSpeed: 0,
                      groundSpeed: 0,
                      airSpeed: 0,
                      homeDistance: 0,
                      flightTime: Duration.zero,
                      signal: 100,
                      cpuTemp: 35,
                      raspberryLoad: 10,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                title: "Live Map",
                child: MapPanel(
                  mapWidget: const LiveMapWidget(),
                  onZoomIn: () {},
                  onZoomOut: () {},
                  onCenterDrone: () {},
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                title: "Drone HUD",
                child: const DroneHUD(
                  roll: 0,
                  pitch: 0,
                  yaw: 0,
                  altitude: 0,
                  speed: 0,
                ),
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                title: "Weather",
                child: const WeatherPanel(
                  windSpeed: 0,
                  windDirection: "N/A",
                  temperature: 0,
                  humidity: 0,
                  rainProbability: 0,
                  safeToFly: true,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Autonomous River Surveillance System",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "System Online - Ready for Operations",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Column(
      children: [
        _buildSettingItem(
          icon: Icons.videocam,
          label: "Camera Settings",
          value: "1080P @ 30FPS",
          onTap: () {},
        ),
        const Divider(height: 16),
        _buildSettingItem(
          icon: Icons.sensors,
          label: "AI Model",
          value: "YOLO v8",
          onTap: () {},
        ),
        const Divider(height: 16),
        _buildSettingItem(
          icon: Icons.map,
          label: "Map Provider",
          value: "OpenStreetMap",
          onTap: () {},
        ),
        const Divider(height: 16),
        _buildSettingItem(
          icon: Icons.save,
          label: "Data Storage",
          value: "Auto-Save Enabled",
          onTap: () {},
        ),
        const Divider(height: 16),
        _buildSettingItem(
          icon: Icons.info,
          label: "System Info",
          value: "v1.0.0",
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade600, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Responsive layout widget for left and right panel arrangement
class ResponsiveDashboardLayout extends StatelessWidget {
  final Widget left;
  final Widget right;

  const ResponsiveDashboardLayout({
    super.key,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1200;

    if (isSmallScreen) {
      // Stack panels vertically on small screens
      return Column(
        children: [
          left,
          const SizedBox(height: 24),
          right,
        ],
      );
    }

    // Side-by-side layout on large screens
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: left,
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: right,
        ),
      ],
    );
  }
}
