import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.dateLabel,
  });

  final String title;
  final String description;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Workout',
      child: ListView(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text(dateLabel, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.lg),
                Text(description, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comments', style: AppTextStyles.title),
                SizedBox(height: AppSpacing.md),
                Text('Comments will appear here'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
