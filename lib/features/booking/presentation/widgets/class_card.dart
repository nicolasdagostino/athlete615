import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import 'class_capacity_badge.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({
    super.key,
    required this.name,
    required this.coachName,
    required this.timeLabel,
    required this.bookedCount,
    required this.capacity,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    this.isBooked = false,
  });

  final String name;
  final String coachName;
  final String timeLabel;
  final int bookedCount;
  final int capacity;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onPrimaryPressed;
  final bool isBooked;

  int get spotsLeft {
    final value = capacity - bookedCount;
    return value < 0 ? 0 : value;
  }

  bool get isFull => spotsLeft <= 0;

  @override
  Widget build(BuildContext context) {
    final spotsText = isFull ? 'No spots left' : '$spotsLeft spots left';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.title,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ClassCapacityBadge(
                bookedCount: bookedCount,
                capacity: capacity,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              _InfoChip(
                icon: Icons.schedule_outlined,
                label: timeLabel,
              ),
              _InfoChip(
                icon: Icons.person_outline,
                label: coachName,
              ),
              if (isBooked)
                const _StatusChip(
                  label: 'Booked',
                  color: Colors.blue,
                  icon: Icons.check_circle_outline,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: primaryLabel,
            icon: primaryIcon,
            onPressed: onPrimaryPressed,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
