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
    required this.spotsLeft,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimaryPressed,
    this.isBooked = false,
  });

  final String name;
  final String coachName;
  final String timeLabel;
  final int spotsLeft;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback? onPrimaryPressed;
  final bool isBooked;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.title,
                ),
              ),
              if (isBooked) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Booked',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              ClassCapacityBadge(spotsLeft: spotsLeft),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            timeLabel,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Coach: $coachName',
            style: AppTextStyles.caption,
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
