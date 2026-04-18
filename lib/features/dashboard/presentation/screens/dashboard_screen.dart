import 'dart:async';

import 'package:flutter/material.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../features/admin/presentation/screens/class_roster_screen.dart';
import '../../../../features/admin/presentation/screens/classes_screen.dart';
import '../../../../features/admin/presentation/screens/members_screen.dart';
import '../../../../features/admin/presentation/widgets/admin_shortcuts_grid.dart';
import '../../../../features/memberships/presentation/screens/plans_screen.dart';
import '../../../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/cards/stat_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/dashboard_repository_impl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repo = DashboardRepositoryImpl();

  bool _loading = true;
  bool _refreshing = false;
  DashboardSummary? _summary;
  List<DashboardUpcomingClass> _upcoming = const [];
  DashboardWeeklyComparison? _weeklyComparison;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshSilently(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (silent) {
      if (_refreshing) return;
      _refreshing = true;
    }

    final summary = await _repo.getSummary();
    final upcoming = await _repo.listUpcomingClasses();
    final weeklyComparison = await _repo.getWeeklyComparison();

    if (!mounted) return;

    setState(() {
      _summary = summary;
      _upcoming = upcoming;
      _weeklyComparison = weeklyComparison;
      _loading = false;
    });

    _refreshing = false;
  }

  Future<void> _refresh() async {
    await _load();
  }

  Future<void> _refreshSilently() async {
    await _load(silent: true);
  }

  Future<void> _openRoster(DashboardUpcomingClass item) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassRosterScreen(
          classId: item.id,
          className: item.name,
        ),
      ),
    );

    await _load();
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day/$month · $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Dashboard',
        child: AppLoader(label: 'Loading dashboard...'),
      );
    }

    final summary = _summary;
    final weekly = _weeklyComparison;

    return AppScaffold(
      title: 'Dashboard',
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            StatCard(
              label: 'Classes today',
              value: '${summary?.classesToday ?? 0}',
              icon: Icons.fitness_center_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            StatCard(
              label: 'Booked today',
              value: '${summary?.bookedToday ?? 0}',
              icon: Icons.calendar_today_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            StatCard(
              label: 'Attended today',
              value: '${summary?.attendedToday ?? 0}',
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: AppSpacing.md),
            StatCard(
              label: 'Occupancy today',
              value: '${summary?.occupancyToday.toStringAsFixed(1) ?? '0'}%',
              icon: Icons.bar_chart_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            StatCard(
              label: 'Upcoming classes',
              value: '${summary?.upcomingClassesCount ?? 0}',
              icon: Icons.schedule_outlined,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('Weekly comparison', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ComparisonRow(
                    label: 'Bookings',
                    current: weekly?.bookingsLast7d ?? 0,
                    previous: weekly?.bookingsPrev7d ?? 0,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ComparisonRow(
                    label: 'Attended',
                    current: weekly?.attendedLast7d ?? 0,
                    previous: weekly?.attendedPrev7d ?? 0,
                  ),
                ],
              ),
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
            const Text('Upcoming classes', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            if (_upcoming.isEmpty)
              const AppCard(
                child: Text('No upcoming classes'),
              )
            else
              ..._upcoming.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: AppCard(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openRoster(item),
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: AppTextStyles.title,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _InfoChip(
                                  icon: Icons.schedule_outlined,
                                  label: _formatDateTime(item.startsAt),
                                ),
                                _InfoChip(
                                  icon: Icons.person_outline,
                                  label: item.coachName,
                                ),
                                _InfoChip(
                                  icon: Icons.people_outline,
                                  label: '${item.bookedCount}/${item.capacity} booked',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.current,
    required this.previous,
  });

  final String label;
  final int current;
  final int previous;

  @override
  Widget build(BuildContext context) {
    final diff = current - previous;
    final positive = diff >= 0;
    final diffLabel = previous == 0
        ? (current == 0 ? '0' : '+$current')
        : '${positive ? '+' : ''}$diff';

    final color = positive ? Colors.green : Colors.red;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '$current',
          style: AppTextStyles.title,
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            diffLabel,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
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
