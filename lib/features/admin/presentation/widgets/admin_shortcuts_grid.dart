import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/cards/app_card.dart';

class AdminShortcutsGrid extends StatelessWidget {
  const AdminShortcutsGrid({
    super.key,
    required this.onTapClasses,
    required this.onTapMembers,
    required this.onTapPlans,
    required this.onTapNotifications,
  });

  final VoidCallback onTapClasses;
  final VoidCallback onTapMembers;
  final VoidCallback onTapPlans;
  final VoidCallback onTapNotifications;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.35,
      children: [
        _ShortcutCard(
          icon: Icons.calendar_today_outlined,
          label: 'Classes',
          onTap: onTapClasses,
        ),
        _ShortcutCard(
          icon: Icons.group_outlined,
          label: 'Members',
          onTap: onTapMembers,
        ),
        _ShortcutCard(
          icon: Icons.card_membership_outlined,
          label: 'Plans',
          onTap: onTapPlans,
        ),
        _ShortcutCard(
          icon: Icons.notifications_outlined,
          label: 'Notify',
          onTap: onTapNotifications,
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(label),
          ],
        ),
      ),
    );
  }
}
