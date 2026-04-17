import 'package:flutter/material.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/admin/presentation/screens/members_screen.dart';
import '../../../../features/admin/presentation/screens/classes_screen.dart';
import '../../../../features/admin/presentation/widgets/admin_shortcuts_grid.dart';
import '../../../../features/memberships/presentation/screens/plans_screen.dart';
import '../../../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      child: ListView(
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gym', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppSession.gymName ?? 'No gym selected',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Role: ${AppSession.roleLabel}',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const StatCard(
            label: 'Active members',
            value: '148',
            icon: Icons.group_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const StatCard(
            label: 'Bookings this week',
            value: '212',
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const StatCard(
            label: 'Classes this week',
            value: '26',
            icon: Icons.fitness_center_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const StatCard(
            label: 'Average occupancy',
            value: '78%',
            icon: Icons.bar_chart_outlined,
          ),
          const SizedBox(height: AppSpacing.md),
          const StatCard(
            label: 'Revenue this month',
            value: '€4,250',
            icon: Icons.euro_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Quick actions', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          AdminShortcutsGrid(
            onTapClasses: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ClassesScreen(),
                ),
              );
            },
            onTapMembers: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MembersScreen(),
                ),
              );
            },
            onTapPlans: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PlansScreen(),
                ),
              );
            },
            onTapNotifications: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const NotificationsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Recent activity', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          const AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityRow(text: '12 new bookings today'),
                SizedBox(height: AppSpacing.sm),
                _ActivityRow(text: '3 memberships renewed'),
                SizedBox(height: AppSpacing.sm),
                _ActivityRow(text: '1 class reached full capacity'),
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
