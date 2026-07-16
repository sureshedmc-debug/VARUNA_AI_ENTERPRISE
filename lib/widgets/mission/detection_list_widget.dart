import 'package:flutter/material.dart';

import '../../models/detection_model.dart';

class DetectionListWidget extends StatelessWidget {
  final List<DetectionModel> detections;

  const DetectionListWidget({super.key, required this.detections});

  static const List<_SampleDetection> _samples = [
    _SampleDetection('Plastic Bottle', 0.97, Color(0xFF42A5F5), Icons.water_drop),
    _SampleDetection('Glass Fragment', 0.89, Color(0xFF26C6DA), Icons.wine_bar),
    _SampleDetection('Metal Can', 0.92, Color(0xFF90A4AE), Icons.construction),
    _SampleDetection('Organic Waste', 0.85, Color(0xFF66BB6A), Icons.eco),
    _SampleDetection('Paper Waste', 0.78, Color(0xFFFFCA28), Icons.article),
    _SampleDetection('E-Waste', 0.91, Color(0xFFAB47BC), Icons.devices),
  ];

  Color _colorForLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('plastic')) return const Color(0xFF42A5F5);
    if (lower.contains('glass')) return const Color(0xFF26C6DA);
    if (lower.contains('metal')) return const Color(0xFF90A4AE);
    if (lower.contains('organic')) return const Color(0xFF66BB6A);
    if (lower.contains('paper')) return const Color(0xFFFFCA28);
    if (lower.contains('e-waste') || lower.contains('electronic')) {
      return const Color(0xFFAB47BC);
    }
    if (lower.contains('hazard')) return Colors.red;
    return Colors.orange;
  }

  String _timeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final count =
        detections.isEmpty ? _samples.length : detections.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A5F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF42A5F5), size: 16),
          const SizedBox(width: 8),
          const Text(
            'AI DETECTIONS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 1.0,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count ITEMS',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (detections.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _samples.length,
        itemBuilder: (context, index) {
          final d = _samples[index];
          return _DetectionTile(
            label: d.label,
            confidence: d.confidence,
            color: d.color,
            icon: d.icon,
            timeAgo: '${index + 1}m ago',
          );
        },
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: detections.length,
      itemBuilder: (context, index) {
        final d = detections[index];
        return _DetectionTile(
          label: d.label,
          confidence: d.confidence,
          color: _colorForLabel(d.label),
          icon: Icons.search,
          timeAgo: _timeAgo(d.timestamp),
        );
      },
    );
  }
}

class _SampleDetection {
  final String label;
  final double confidence;
  final Color color;
  final IconData icon;

  const _SampleDetection(this.label, this.confidence, this.color, this.icon);
}

class _DetectionTile extends StatelessWidget {
  final String label;
  final double confidence;
  final Color color;
  final IconData icon;
  final String timeAgo;

  const _DetectionTile({
    required this.label,
    required this.confidence,
    required this.color,
    required this.icon,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(confidence * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
