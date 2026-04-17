import 'package:flutter/material.dart';

class ClassCapacityBadge extends StatelessWidget {
  const ClassCapacityBadge({
    super.key,
    required this.spotsLeft,
  });

  final int spotsLeft;

  @override
  Widget build(BuildContext context) {
    final color = spotsLeft > 3
        ? Colors.green
        : spotsLeft > 0
            ? Colors.orange
            : Colors.red;

    final text = spotsLeft > 0 ? '$spotsLeft spots left' : 'Full';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
