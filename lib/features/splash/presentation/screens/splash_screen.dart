import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _continue(BuildContext context) {
    final nextRoute = AppSession.hasActiveSession
        ? RouteNames.selectGym
        : RouteNames.login;

    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final label = AppSession.hasActiveSession ? 'Continue session' : 'Continue';

    return AppScaffold(
      title: 'ATH615',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('ATH615', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Professional multi-gym app foundation',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: label,
                  icon: Icons.login,
                  onPressed: () => _continue(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
