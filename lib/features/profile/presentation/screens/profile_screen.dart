import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/config/env.dart';
import '../../../../infra/auth/auth_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/enums/app_role.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import 'personal_records_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    if (Env.isSupabaseConfigured) {
      await AuthRepository().signOut();
    }

    AppSession.clear();
    if (!context.mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (route) => false,
    );
  }

  bool get _canSeePersonalRecords {
    return AppSession.role == AppRole.athlete;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      child: ListView(
        children: [
          AppCard(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppSession.fullName, style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(AppSession.email, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current gym', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppSession.gymName ?? 'No gym selected',
                  style: AppTextStyles.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Role: ${AppSession.roleLabel}',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                if (_canSeePersonalRecords) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.emoji_events_outlined),
                    title: const Text('Personal Records'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PersonalRecordsScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.business_outlined),
                  title: const Text('Change gym'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      RouteNames.selectGym,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
