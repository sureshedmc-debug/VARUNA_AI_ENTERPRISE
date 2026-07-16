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
        title: const Text("VARUNA AI Enterprise"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SystemStatusBar(
              raspberryPi: false,
              pixhawk: false,
              gps: false,
              ai: false,
              camera: false,
              battery: 100,
              satellites: 0,
            ),

            const SizedBox(height: 16),

            const PreFlightChecklist(
              checks: {
                "Raspberry Pi": false,
                "Pixhawk": false,
                "GPS Lock": false,
                "Camera Ready": false,
                "AI Loaded": false,
                "Battery > 40%": true,
              },
            ),

            const SizedBox(height: 16),

            CameraPanel(
              videoWidget: const LiveVideoWidget(),
              recording: false,
              resolution: "1080P",
              fps: 30,
              onSnapshot: () {},
              onToggleOverlay: () {},
            ),

            const SizedBox(height: 16),

            const MissionControls(),

            const SizedBox(height: 16),

            const TelemetryPanel(
              altitude: 0,
              speed: 0,
              heading: 0,
              flightMode: "WAITING",
              battery: 100,
              satellites: 0,
            ),

            const SizedBox(height: 16),

            MapPanel(
              mapWidget: const LiveMapWidget(),
              onZoomIn: () {},
              onZoomOut: () {},
              onCenterDrone: () {},
            ),

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

            const WeatherPanel(
              windSpeed: 0,
              windDirection: "N/A",
              temperature: 0,
              humidity: 0,
              rainProbability: 0,
              safeToFly: true,
            ),

            const SizedBox(height: 16),

            const MissionTimelinePanel(
              currentStep: 0,
            ),

            const SizedBox(height: 16),

            const DroneHUD(
              roll: 0,
              pitch: 0,
              yaw: 0,
              altitude: 0,
              speed: 0,
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

            const SizedBox(height: 16),

            const MissionSummaryCard(
              missionType: "None",
              waypoints: 0,
              estimatedMinutes: 0,
              estimatedArea: 0,
              batteryRequired: 0,
              aiModel: "YOLO",
            ),

            const SizedBox(height: 16),

            FlightControlPanel(
              onArm: () {},
              onDisarm: () {},
              onTakeoff: () {},
              onRTL: () {},
              onLand: () {},
              onEmergency: () {},
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}