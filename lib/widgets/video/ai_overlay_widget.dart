import 'package:flutter/material.dart';

import '../../services/ai/ai_copilot_service.dart';
import '../../services/detection/object_detector.dart';

class AIOverlayWidget extends StatelessWidget {
  final List<DetectionResult> detections;

  const AIOverlayWidget({
    super.key,
    required this.detections,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          for (final d in detections)
            Positioned(
              left: d.left,
              top: d.top,
              width: d.width,
              height: d.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.green,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    color: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      '${d.label} ${(d.confidence*100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 12,
            top: 12,
            child: AnimatedBuilder(
              animation: AICopilotService.instance,
              builder: (context, _) {
                final advice = AICopilotService.instance.currentAdvice;
                return Card(
                  color: Colors.black87,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      advice.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

