import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <_NotificationItem>[
      _NotificationItem(
        title: 'New class published',
        body: 'Friday 18:00 class is now available for booking.',
      ),
      _NotificationItem(
        title: 'Membership reminder',
        body: '3 athletes have memberships expiring this week.',
      ),
      _NotificationItem(
        title: 'Gym announcement',
        body: 'Holiday schedule will be sent tomorrow.',
      ),
    ];

    return AppScaffold(
      title: 'Notifications',
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text(item.body),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
