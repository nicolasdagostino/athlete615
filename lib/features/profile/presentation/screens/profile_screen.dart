import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/config/env.dart';
import '../../../../infra/auth/auth_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/enums/app_role.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/account_repository_impl.dart';
import '../../../booking/data/booking_repository_impl.dart';
import '../../../booking/domain/models/membership_booking_access.dart';
import 'personal_records_screen.dart';
import 'milestones_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'help_center_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _bookingRepo = BookingRepositoryImpl();
  final _accountRepo = AccountRepositoryImpl();

  bool _deletingAccount = false;

  bool _loadingMembership = true;
  MembershipBookingAccess? _membershipAccess;

  @override
  void initState() {
    super.initState();
    _loadMembership();
  }

  Future<void> _loadMembership() async {
    if (AppSession.role != AppRole.athlete) {
      setState(() => _loadingMembership = false);
      return;
    }

    final membership = await _bookingRepo.getMyMembershipBookingAccess();

    if (!mounted) return;

    setState(() {
      _membershipAccess = membership;
      _loadingMembership = false;
    });
  }


  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete account'),
          content: const Text(
            'This will permanently delete your account and related app data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    if (_deletingAccount) return;

    setState(() => _deletingAccount = true);

    try {
      await _accountRepo.deleteMyAccount();
      if (!mounted) return;

      await _logout(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete account: $error')),
      );
      setState(() => _deletingAccount = false);
    }
  }

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
          if (AppSession.role == AppRole.athlete) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: _loadingMembership
                  ? const AppLoader(label: 'Loading membership...')
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Membership', style: AppTextStyles.caption),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _membershipAccess?.planLabel ?? 'No active membership',
                          style: AppTextStyles.title,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _membershipAccess?.detailLabel ?? 'No active membership',
                          style: AppTextStyles.body,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _membershipAccess?.message ?? 'Unavailable',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
            ),
          ],
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
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: const Text('Milestones'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MilestonesScreen(),
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
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TermsOfServiceScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline),
                  title: Text(_deletingAccount ? 'Deleting account...' : 'Delete Account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _deletingAccount ? null : _confirmDeleteAccount,
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
