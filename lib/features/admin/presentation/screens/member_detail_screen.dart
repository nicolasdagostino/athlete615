import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({
    super.key,
    required this.name,
    required this.email,
    required this.role,
  });

  final String name;
  final String email;
  final String role;

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String get _roleLabel {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'coach':
        return 'Coach';
      case 'athlete':
      default:
        return 'Athlete';
    }
  }

  Color get _roleColor {
    switch (role) {
      case 'admin':
        return Colors.orange;
      case 'coach':
        return Colors.purple;
      case 'athlete':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return AppScaffold(
      title: 'Member',
      child: ListView(
        children: [
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _roleLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: _roleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Contact', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(email, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Membership', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Plan data pending',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'This section will use real membership data later.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.card_membership_outlined),
                  title: const Text('Assign plan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMessage(context, 'Assign plan'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Send notification'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMessage(context, 'Send notification'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit member'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMessage(context, 'Edit member'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activity', style: AppTextStyles.title),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Activity data pending',
                  style: AppTextStyles.body,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Recent bookings, attendance and membership events will appear here later.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
