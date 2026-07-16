import 'package:flutter/material.dart';

class PreflightChecklistItem extends StatefulWidget {
  final String title;
  final bool isCompleted;

  const PreflightChecklistItem({
    super.key,
    required this.title,
    required this.isCompleted,
  });

  @override
  State<PreflightChecklistItem> createState() =>
      _PreflightChecklistItemState();
}

class _PreflightChecklistItemState extends State<PreflightChecklistItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    if (widget.isCompleted) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(PreflightChecklistItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.grey.shade300,
                  Colors.green.shade400,
                  _animationController.value,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _animationController.value > 0.5
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            );
          },
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: widget.isCompleted
                  ? Colors.green.shade600
                  : Colors.grey.shade600,
              decoration: widget.isCompleted
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
