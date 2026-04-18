import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Help Center',
      child: ListView(
        children: const [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Need help?', style: AppTextStyles.title),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'For support with bookings, memberships, workouts, or account access, contact your gym administrator first.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Common topics', style: AppTextStyles.title),
                SizedBox(height: AppSpacing.md),
                _HelpRow(text: 'Booking and cancellation issues'),
                SizedBox(height: AppSpacing.sm),
                _HelpRow(text: 'Membership credits and renewals'),
                SizedBox(height: AppSpacing.sm),
                _HelpRow(text: 'Workout comments, likes, and history'),
                SizedBox(height: AppSpacing.sm),
                _HelpRow(text: 'Gym access and profile questions'),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Support contact', style: AppTextStyles.title),
                SizedBox(height: AppSpacing.sm),
                Text('Email: support@athletelab.app', style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 8),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ],
    );
  }
}
