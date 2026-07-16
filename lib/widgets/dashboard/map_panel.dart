import 'package:flutter/material.dart';

class MapPanel extends StatelessWidget {
  final Widget mapWidget;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenterDrone;

  const MapPanel({
    super.key,
    required this.mapWidget,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onCenterDrone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.map, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Mission Map',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 400,
                width: double.infinity,
                child: mapWidget,
              ),
            ),

            const SizedBox(height: 15),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [

                ElevatedButton.icon(
                  onPressed: onCenterDrone,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Center Drone'),
                ),

                OutlinedButton.icon(
                  onPressed: onZoomIn,
                  icon: const Icon(Icons.zoom_in),
                  label: const Text('Zoom In'),
                ),

                OutlinedButton.icon(
                  onPressed: onZoomOut,
                  icon: const Icon(Icons.zoom_out),
                  label: const Text('Zoom Out'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}