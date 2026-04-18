import 'package:flutter/material.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/enums/app_role.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/workouts_repository_impl.dart';
import '../../domain/models/workout_summary.dart';
import 'workout_detail_screen.dart';
import 'create_workout_screen.dart';
import 'manage_workouts_screen.dart';
import '../widgets/workout_card.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  final _repo = WorkoutsRepositoryImpl();

  bool get _canCreateWorkout {
    final role = AppSession.role;
    return role == AppRole.admin || role == AppRole.coach || role == AppRole.owner;
  }


  Future<void> _openManageWorkouts() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ManageWorkoutsScreen(),
      ),
    );

    await _load();
  }

  Future<void> _openCreateWorkout() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateWorkoutScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }

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
      floatingActionButton: _canCreateWorkout
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'manage_workouts',
                  onPressed: _openManageWorkouts,
                  child: const Icon(Icons.edit_outlined),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'create_workout',
                  onPressed: _openCreateWorkout,
                  child: const Icon(Icons.add),
                ),
              ],
            )
          : null,
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
