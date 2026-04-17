import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateLabel,
    required this.likesCount,
    required this.commentsCount,
    required this.onOpen,
  });

  final String title;
  final String description;
  final String dateLabel;
  final int likesCount;
  final int commentsCount;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text(
            dateLabel,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: AppTextStyles.body,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.favorite_border, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: AppSpacing.xs),
              Text('$likesCount'),
              const SizedBox(width: AppSpacing.md),
              Icon(Icons.mode_comment_outlined, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: AppSpacing.xs),
              Text('$commentsCount'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'Open workout',
            icon: Icons.arrow_forward,
            onPressed: onOpen,
          ),
        ],
      ),
    );
  }
}
