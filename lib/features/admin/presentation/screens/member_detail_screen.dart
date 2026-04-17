import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class MemberDetailScreen extends StatelessWidget {
  const MemberDetailScreen({
    super.key,
    required this.name,
    required this.plan,
    required this.status,
  });

  final String name;
  final String plan;
  final String status;

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Member',
      child: ListView(
        children: [
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Status: $status', style: AppTextStyles.caption),
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
                const Text('Membership', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(plan, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.md),
                const Text('Email', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${name.toLowerCase().replaceAll(' ', '.')}@gym.com',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text('Phone', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                const Text('+34 600 123 456', style: AppTextStyles.body),
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
                Text('Recent activity', style: AppTextStyles.title),
                SizedBox(height: AppSpacing.md),
                _ActivityRow(text: 'Booked CrossFit on Monday'),
                SizedBox(height: AppSpacing.sm),
                _ActivityRow(text: 'Membership renewed this month'),
                SizedBox(height: AppSpacing.sm),
                _ActivityRow(text: 'Commented on Monday WOD'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
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
