import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/workouts_repository_impl.dart';
import '../../domain/models/workout_summary.dart';
import 'workout_detail_screen.dart';
import '../widgets/workout_card.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _repo = WorkoutsRepositoryImpl();

  bool _loading = true;
  List<WorkoutSummary> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.listTodayWorkouts();

    if (!mounted) return;

    setState(() {
      _items = items;
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
        title: 'Workouts',
        child: AppLoader(label: 'Loading workouts...'),
      );
    }

    return AppScaffold(
      title: 'Workouts',
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: _items.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('No workouts for today', style: AppTextStyles.title),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          'When a workout is published for today, it will appear here.',
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = _items[index];

                  return WorkoutCard(
                    title: item.title,
                    description: item.description,
                    dateLabel: item.programLabel,
                    likesCount: item.likesCount,
                    commentsCount: item.commentsCount,
                    onOpen: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workoutId: item.id,
                            title: item.title,
                            description: item.description,
                            dateLabel: item.programLabel,
                            likesCount: item.likesCount,
                            commentsCount: item.commentsCount,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
