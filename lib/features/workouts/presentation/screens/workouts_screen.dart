import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import 'workout_detail_screen.dart';
import '../widgets/workout_card.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <_WorkoutItem>[
      _WorkoutItem(
        title: 'Monday WOD',
        dateLabel: 'Today · 07:00',
        description:
            'For time: 21-15-9 thrusters and pull-ups. Then finish with a short core burner.',
        likesCount: 12,
        commentsCount: 4,
      ),
      _WorkoutItem(
        title: 'Strength Day',
        dateLabel: 'Yesterday · 18:00',
        description:
            'Build to a heavy front squat, then 3 rounds of 12 burpees and 400m run.',
        likesCount: 8,
        commentsCount: 2,
      ),
      _WorkoutItem(
        title: 'Partner Workout',
        dateLabel: 'Saturday · 10:00',
        description:
            'AMRAP 20 with your partner: sync burpees, DB snatches, and row calories.',
        likesCount: 15,
        commentsCount: 7,
      ),
    ];

    return AppScaffold(
      title: 'Workouts',
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = items[index];
          return WorkoutCard(
            title: item.title,
            description: item.description,
            dateLabel: item.dateLabel,
            likesCount: item.likesCount,
            commentsCount: item.commentsCount,
            onOpen: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => WorkoutDetailScreen(
                    title: item.title,
                    description: item.description,
                    dateLabel: item.dateLabel,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WorkoutItem {
  const _WorkoutItem({
    required this.title,
    required this.dateLabel,
    required this.description,
    required this.likesCount,
    required this.commentsCount,
  });

  final String title;
  final String dateLabel;
  final String description;
  final int likesCount;
  final int commentsCount;
}
