
import 'package:flutter/material.dart';

import '../../widgets/battery_gauge.dart';
import '../../widgets/status_card.dart';

import '../map/map_screen.dart';
import '../camera/camera_screen.dart';
import '../ai/ai_screen.dart';
import '../reports/reports_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Widget actionButton(
    BuildContext context,
    IconData icon,
    String title,
    Color color,
    Widget page,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Card(
        color: const Color(0xFF102A43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(
              icon,
              color: color,
              size: 42,
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff061B34),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,

        title: const Text(
          "VARUNA AI",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        actions: const [

          Padding(
            padding: EdgeInsets.only(right: 18),

            child: Icon(
              Icons.notifications_active,
              color: Colors.cyan,
            ),

          )

        ],

      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            Row(

              children: [

                const Icon(
                  Icons.circle,
                  size: 14,
                  color: Colors.green,
                ),

                const SizedBox(width: 8),

                const Text(
                  "Drone Connected",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: const Text(
                    "ONLINE",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                )

              ],

            ),

            const SizedBox(height: 20),

            const BatteryGauge(
              battery: 98,
            ),

            const SizedBox(height: 20),

            const StatusCard(
              icon: Icons.gps_fixed,
              title: "GPS",
              value: "16 Satellites",
              color: Colors.cyan,
            ),

            const StatusCard(
              icon: Icons.height,
              title: "Altitude",
              value: "15.6 m",
              color: Colors.green,
            ),

            const StatusCard(
              icon: Icons.speed,
              title: "Speed",
              value: "2.6 m/s",
              color: Colors.orange,
            ),

            const StatusCard(
              icon: Icons.explore,
              title: "Heading",
              value: "125°",
              color: Colors.purple,
            ),

            const SizedBox(height: 25),

            GridView.count(

              shrinkWrap: true,

              physics: const NeverScrollableScrollPhysics(),

              crossAxisCount: 2,

              crossAxisSpacing: 15,

              mainAxisSpacing: 15,

              childAspectRatio: 1.15,

              children: [

                actionButton(
                  context,
                  Icons.map,
                  "Live Map",
                  Colors.blue,
                  const MapScreen(),
                ),

                actionButton(
                  context,
                  Icons.videocam,
                  "Camera",
                  Colors.red,
                  const CameraScreen(),
                ),

                actionButton(
                  context,
                  Icons.auto_awesome,
                  "AI Detection",
                  Colors.deepPurple,
                  const AIScreen(),
                ),

                actionButton(
                  context,
                  Icons.analytics,
                  "Reports",
                  Colors.orange,
                  const ReportsScreen(),
                ),

              ],

            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),

                onPressed: () {},

                icon: const Icon(Icons.rocket_launch),

                label: const Text(
                  "START MISSION",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ),

            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),

                onPressed: () {},

                icon: const Icon(Icons.home),

                label: const Text(
                  "RETURN HOME",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}