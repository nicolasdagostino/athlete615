import 'package:flutter/material.dart';

class ClassCapacityBadge extends StatelessWidget {
  const ClassCapacityBadge({
    super.key,
    required this.bookedCount,
    required this.capacity,
  });

  final int bookedCount;
  final int capacity;

  int get spotsLeft {
    final value = capacity - bookedCount;
    return value < 0 ? 0 : value;
  }

  bool get isFull => spotsLeft <= 0;

  @override
  Widget build(BuildContext context) {
    final ratio = capacity <= 0 ? 1.0 : bookedCount / capacity;

    final color = isFull
        ? Colors.red
        : ratio >= 0.8
            ? Colors.orange
            : Colors.green;

    final label = isFull
        ? 'FULL'
        : '$bookedCount/$capacity';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
