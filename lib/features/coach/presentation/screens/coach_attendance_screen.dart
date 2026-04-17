import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class CoachAttendanceScreen extends StatelessWidget {
  const CoachAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const classes = <_AttendanceClassItem>[
      _AttendanceClassItem(
        title: 'CrossFit',
        timeLabel: '07:00 - 08:00',
        athletes: 12,
      ),
      _AttendanceClassItem(
        title: 'Weightlifting',
        timeLabel: '18:00 - 19:00',
        athletes: 8,
      ),
      _AttendanceClassItem(
        title: 'Gymnastics',
        timeLabel: '19:00 - 20:00',
        athletes: 10,
      ),
    ];

    return AppScaffold(
      title: 'Attendance',
      child: ListView.separated(
        itemCount: classes.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final item = classes[index];
          return AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.title, style: AppTextStyles.title),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('${item.timeLabel} · ${item.athletes} athletes'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Open roster for ${item.title}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AttendanceClassItem {
  const _AttendanceClassItem({
    required this.title,
    required this.timeLabel,
    required this.athletes,
  });

  final String title;
  final String timeLabel;
  final int athletes;
}
