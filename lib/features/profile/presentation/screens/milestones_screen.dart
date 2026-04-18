import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/profile_repository_impl.dart';
import '../../domain/models/attendance_milestone_summary.dart';

class MilestonesScreen extends StatefulWidget {
  const MilestonesScreen({super.key});

  @override
  State<MilestonesScreen> createState() => _MilestonesScreenState();
}

class _MilestonesScreenState extends State<MilestonesScreen> {
  final _repo = ProfileRepositoryImpl();

  static const _milestones = <int>[10, 25, 50, 100];

  bool _loading = true;
  AttendanceMilestoneSummary? _summary;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final summary = await _repo.getAttendanceMilestones();

    if (!mounted) return;

    setState(() {
      _summary = summary;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Milestones',
        child: AppLoader(label: 'Loading milestones...'),
      );
    }

    final attended = _summary?.attendedCount ?? 0;

    return AppScaffold(
      title: 'Milestones',
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Attendance progress', style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$attended classes attended',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'Your milestones unlock as you keep showing up.',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(_milestones.length, (index) {
              final goal = _milestones[index];
              final unlocked = attended >= goal;
              final progress = goal == 0
                  ? 0.0
                  : (attended / goal).clamp(0, 1).toDouble();

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _milestones.length - 1 ? 0 : AppSpacing.md,
                ),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$goal classes milestone',
                              style: AppTextStyles.title,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: (unlocked ? Colors.green : Colors.orange)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              unlocked ? 'Unlocked' : 'In progress',
                              style: AppTextStyles.caption.copyWith(
                                color: unlocked ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        unlocked
                            ? 'Completed'
                            : '$attended / $goal classes',
                        style: AppTextStyles.body,
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
