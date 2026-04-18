import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Privacy Policy',
      child: _LegalBody(
        sections: [
          _LegalSection(
            title: 'Overview',
            body:
                'Athlete Lab collects the information needed to provide gym management, bookings, workouts, memberships, and notifications inside the app.',
          ),
          _LegalSection(
            title: 'Data we use',
            body:
                'We may store your profile details, gym membership data, class bookings, workout interactions such as likes and comments, and app usage data required to operate the service.',
          ),
          _LegalSection(
            title: 'Why we use it',
            body:
                'We use your data to authenticate your account, connect you with your gym, manage bookings, publish workouts, support memberships, and improve the product experience.',
          ),
          _LegalSection(
            title: 'Sharing',
            body:
                'Your data is only shared as needed to operate the service for your gym. We do not sell personal data.',
          ),
          _LegalSection(
            title: 'Retention',
            body:
                'We keep data while your account remains active or while it is needed to provide the service and comply with legal obligations.',
          ),
          _LegalSection(
            title: 'Your rights',
            body:
                'You can request account deletion and review or update your information through the app or by contacting support.',
          ),
        ],
      ),
    );
  }
}

class _LegalBody extends StatelessWidget {
  const _LegalBody({
    required this.sections,
  });

  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const AppCard(
          child: Text(
            'Last updated: April 2026',
            style: AppTextStyles.caption,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(sections.length, (index) {
          final section = sections[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == sections.length - 1 ? 0 : AppSpacing.md,
            ),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title, style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(section.body, style: AppTextStyles.body),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _LegalSection {
  const _LegalSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
