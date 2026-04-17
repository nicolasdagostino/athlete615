import 'package:flutter/material.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../gym_context/presentation/screens/create_gym_screen.dart';
import '../../data/owner_repository_impl.dart';
import '../../domain/models/owner_gym_summary.dart';
import '../widgets/gym_summary_card.dart';
import 'invite_user_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final _repo = OwnerRepositoryImpl();

  bool _loading = true;
  List<OwnerGymSummary> _gyms = const [];
  List<Map<String, dynamic>> _invites = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gyms = await _repo.listOwnedGyms();
    final invites = await _repo.listRecentInvites();

    if (!mounted) return;

    setState(() {
      _gyms = gyms;
      _invites = invites;
      _loading = false;
    });
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _openCreateGym(BuildContext context) async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreateGymScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }

  Future<void> _openInviteUser(BuildContext context) async {
    if (AppSession.gymId == null) {
      _showMessage(context, 'Select a gym first');
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const InviteUserScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Owner Home',
        child: AppLoader(label: 'Loading owner data...'),
      );
    }

    return AppScaffold(
      title: 'Owner Home',
      child: ListView(
        children: [
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_business_outlined),
                  title: const Text('Create gym'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openCreateGym(context),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_add_alt_1_outlined),
                  title: const Text('Invite user'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openInviteUser(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Your gyms', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          if (_gyms.isEmpty)
            const AppCard(
              child: Text('No gyms created yet'),
            )
          else
            ..._gyms.map(
              (gym) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: GymSummaryCard(
                  name: gym.name,
                  isSelected: AppSession.gymId == gym.id,
                  onTap: () {
                    AppSession.setGymContext(
                      id: gym.id,
                      name: gym.name,
                    );
                    setState(() {});
                    _showMessage(context, 'Current gym updated');
                  },
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Recent invites', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          if (_invites.isEmpty)
            const AppCard(
              child: Text('No invites yet'),
            )
          else
            ..._invites.map(
              (invite) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(invite['email'] as String),
                    subtitle: Text(
                      '${invite['role']} · ${(invite['accepted'] as bool) ? 'accepted' : 'pending'}',
                    ),
                    trailing: Icon(
                      (invite['accepted'] as bool)
                          ? Icons.check_circle_outline
                          : Icons.schedule,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Summary', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text('${_gyms.length}', style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                const Text('Gyms managed'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
