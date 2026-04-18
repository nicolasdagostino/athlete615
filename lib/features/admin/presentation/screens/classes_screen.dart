import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/admin_repository_impl.dart';
import '../../domain/models/admin_class_summary.dart';
import 'class_roster_screen.dart';
import 'create_class_screen.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  final _repo = AdminRepositoryImpl();

  bool _loading = true;
  List<AdminClassSummary> _classes = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _openCreateClass() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateClassScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }

  Future<void> _load() async {
    final items = await _repo.listGymClasses();

    if (!mounted) return;

    setState(() {
      _classes = items;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
  }

  void _openRoster(AdminClassSummary item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClassRosterScreen(
          classId: item.id,
          className: item.name,
        ),
      ),
    );
  }

  int get _totalCapacity =>
      _classes.fold(0, (sum, item) => sum + item.capacity);

  int get _totalBooked =>
      _classes.fold(0, (sum, item) => sum + item.bookedCount);

  int get _totalSpotsLeft =>
      _classes.fold(0, (sum, item) => sum + item.spotsLeft);

  String _formatDate(DateTime value) {
    final y = value.year.toString().padLeft(4, '0');
    final m = value.month.toString().padLeft(2, '0');
    final d = value.day.toString().padLeft(2, '0');
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$y-$m-$d · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Classes',
        child: AppLoader(label: 'Loading classes...'),
      );
    }

    return AppScaffold(
      title: 'Classes',
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateClass,
        child: const Icon(Icons.add),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: _classes.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No classes found for this gym'),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  AppCard(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _SummaryChip(
                          label: 'Classes',
                          value: _classes.length.toString(),
                          color: Colors.blue,
                          icon: Icons.calendar_month_outlined,
                        ),
                        _SummaryChip(
                          label: 'Booked',
                          value: _totalBooked.toString(),
                          color: Colors.orange,
                          icon: Icons.event_available_outlined,
                        ),
                        _SummaryChip(
                          label: 'Capacity',
                          value: _totalCapacity.toString(),
                          color: Colors.black87,
                          icon: Icons.groups_outlined,
                        ),
                        _SummaryChip(
                          label: 'Spots left',
                          value: _totalSpotsLeft.toString(),
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(_classes.length, (index) {
                    final item = _classes[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _classes.length - 1 ? 0 : AppSpacing.md,
                      ),
                      child: AppCard(
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
                                _CapacityBadge(
                                  bookedCount: item.bookedCount,
                                  capacity: item.capacity,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              spacing: AppSpacing.sm,
                              runSpacing: AppSpacing.sm,
                              children: [
                                _InfoChip(
                                  icon: Icons.schedule_outlined,
                                  label: _formatDate(item.startsAt),
                                ),
                                _InfoChip(
                                  icon: Icons.person_outline,
                                  label: item.coachName,
                                ),
                                _InfoChip(
                                  icon: Icons.timer_outlined,
                                  label: '${item.durationMinutes} min',
                                ),
                                _InfoChip(
                                  icon: Icons.people_outline,
                                  label: '${item.spotsLeft} spots left',
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _openRoster(item),
                                icon: const Icon(Icons.fact_check_outlined),
                                label: const Text('Open roster'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CapacityBadge extends StatelessWidget {
  const _CapacityBadge({
    required this.bookedCount,
    required this.capacity,
  });

  final int bookedCount;
  final int capacity;

  @override
  Widget build(BuildContext context) {
    final ratio = capacity <= 0 ? 1.0 : bookedCount / capacity;

    final color = ratio >= 1
        ? Colors.red
        : ratio >= 0.8
            ? Colors.orange
            : Colors.green;

    final label = ratio >= 1
        ? 'Full • $bookedCount/$capacity'
        : '$bookedCount/$capacity booked';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
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
