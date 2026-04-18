import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Terms of Service',
      child: _LegalBody(
        sections: [
          _LegalSection(
            title: 'Use of the app',
            body:
                'Athlete Lab is provided to help gyms and their members manage bookings, workouts, memberships, and related activity.',
          ),
          _LegalSection(
            title: 'Accounts',
            body:
                'You are responsible for keeping your account information accurate and for maintaining the confidentiality of your login credentials.',
          ),
          _LegalSection(
            title: 'Acceptable use',
            body:
                'You agree not to misuse the app, interfere with the service, access data without authorization, or use the platform for unlawful activity.',
          ),
          _LegalSection(
            title: 'Memberships and bookings',
            body:
                'Gym rules related to credits, reservations, attendance, cancellations, and other policies are defined by each gym and applied through the app.',
          ),
          _LegalSection(
            title: 'Availability',
            body:
                'We aim to keep the service available and reliable, but temporary interruptions or changes may happen while we improve the platform.',
          ),
          _LegalSection(
            title: 'Termination',
            body:
                'We may suspend or terminate access if the app is misused or if continued access would compromise the service or other users.',
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
