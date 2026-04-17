import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/admin_repository_impl.dart';
import '../../domain/models/admin_member_summary.dart';
import 'member_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _repo = AdminRepositoryImpl();

  bool _loading = true;
  List<AdminMemberSummary> _members = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final members = await _repo.listGymMembers();

    if (!mounted) return;

    setState(() {
      _members = members;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Members',
        child: AppLoader(label: 'Loading members...'),
      );
    }

    return AppScaffold(
      title: 'Members',
      child: _members.isEmpty
          ? const Center(
              child: Text('No members found for this gym'),
            )
          : ListView.separated(
              itemCount: _members.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final member = _members[index];
                return AppCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(member.fullName, style: AppTextStyles.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xs),
                      child: Text('${member.email} · ${member.role}'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MemberDetailScreen(
                            name: member.fullName,
                            plan: 'Plan pending',
                            status: member.role,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
