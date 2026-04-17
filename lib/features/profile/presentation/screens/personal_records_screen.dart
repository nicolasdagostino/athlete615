import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../widgets/personal_record_tile.dart';

class PersonalRecordsScreen extends StatelessWidget {
  const PersonalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const records = <Map<String, String>>[
      {'exercise': 'Back Squat', 'value': '140 kg'},
      {'exercise': 'Deadlift', 'value': '180 kg'},
      {'exercise': 'Clean & Jerk', 'value': '95 kg'},
      {'exercise': 'Snatch', 'value': '75 kg'},
    ];

    return AppScaffold(
      title: 'Personal Records',
      child: ListView(
        children: [
          const AppCard(
            child: Text(
              'Your best lifts and benchmark results will live here.',
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                for (int i = 0; i < records.length; i++) ...[
                  PersonalRecordTile(
                    exercise: records[i]['exercise']!,
                    value: records[i]['value']!,
                  ),
                  if (i != records.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
