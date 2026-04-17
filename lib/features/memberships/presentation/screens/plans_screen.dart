import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const plans = <_PlanItem>[
      _PlanItem(name: 'Unlimited', price: '€95 / month', rule: 'Unlimited bookings'),
      _PlanItem(name: '8 Classes', price: '€70 / month', rule: '8 bookings per month'),
      _PlanItem(name: 'Drop-in', price: '€15', rule: 'Single class'),
    ];

    return AppScaffold(
      title: 'Plans',
      child: ListView.separated(
        itemCount: plans.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final plan = plans[index];
          return AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(plan.name, style: AppTextStyles.title),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('${plan.price} · ${plan.rule}'),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }
}

class _PlanItem {
  const _PlanItem({
    required this.name,
    required this.price,
    required this.rule,
  });

  final String name;
  final String price;
  final String rule;
}
