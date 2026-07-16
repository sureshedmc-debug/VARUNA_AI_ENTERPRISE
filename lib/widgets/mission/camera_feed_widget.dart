import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../services/video/video_stream_service.dart';

class CameraFeedWidget extends StatefulWidget {
  const CameraFeedWidget({super.key});

  @override
  State<CameraFeedWidget> createState() => _CameraFeedWidgetState();
}

class _CameraFeedWidgetState extends State<CameraFeedWidget> {
  bool _isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(child: _buildVideoFeed()),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(color: Color(0xFF1E3A5F)),
      child: Row(
        children: [
          const Icon(Icons.videocam, color: Color(0xFF42A5F5), size: 18),
          const SizedBox(width: 8),
          const Text(
            'LIVE AI CAMERA FEED',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isRecording = !_isRecording),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isRecording
                    ? Colors.red.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: _isRecording ? Colors.red : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: _isRecording ? Colors.red : Colors.grey,
                    size: 10,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isRecording ? 'REC' : 'IDLE',
                    style: TextStyle(
                      color: _isRecording ? Colors.red : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFeed() {
    return AnimatedBuilder(
      animation: VideoStreamService.instance,
      builder: (context, _) {
        final service = VideoStreamService.instance;
        return StreamBuilder<Uint8List>(
          stream: service.frames,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return _buildPlaceholder(service.isStreaming);
            }
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
                CustomPaint(painter: _AiOverlayPainter()),
                const Positioned(
                  top: 12,
                  left: 12,
                  child: _LiveBadge(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlaceholder(bool isConnecting) {
    return Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color(0xFF42A5F5), width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.videocam_off,
              color: Color(0xFF42A5F5),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isConnecting
                ? 'Connecting to Raspberry Pi…'
                : 'Camera Offline',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            'Stream: 192.168.4.1:8080',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
          if (isConnecting) ...[
            const SizedBox(height: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF42A5F5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _StatusItem(
            icon: Icons.memory,
            label: 'AI: ACTIVE',
            color: Colors.green,
          ),
          const SizedBox(width: 16),
          _StatusItem(
            icon: Icons.speed,
            label: 'FPS: 30',
            color: Colors.blue,
          ),
          const SizedBox(width: 16),
          _StatusItem(
            icon: Icons.search,
            label: 'Detections: 12',
            color: Colors.orange,
          ),
          const Spacer(),
          _StatusItem(
            icon: _isRecording ? Icons.stop_circle : Icons.play_circle,
            label: _isRecording ? 'Recording' : 'Standby',
            color: _isRecording ? Colors.red : Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.white, size: 8),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _AiOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final boxes = [
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.25,
        size.width * 0.22,
        size.height * 0.18,
      ),
      Rect.fromLTWH(
        size.width * 0.58,
        size.height * 0.40,
        size.width * 0.16,
        size.height * 0.14,
      ),
    ];

    const labels = ['Plastic 0.94', 'Glass 0.87'];
    for (int i = 0; i < boxes.length; i++) {
      canvas.drawRect(boxes[i], paint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: Colors.green,
            fontSize: 9,
            backgroundColor: Color(0xAA000000),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(boxes[i].left, boxes[i].top - 13));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
