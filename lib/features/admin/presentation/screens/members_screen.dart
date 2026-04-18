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

  Future<void> _refresh() async {
    await _load();
  }

  int _countByRole(String role) {
    return _members.where((member) => member.role == role).length;
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
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: _members.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No members found for this gym'),
                  ),
                ],
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  AppCard(
                    child: Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _SummaryChip(
                          label: 'Total',
                          value: _members.length.toString(),
                          color: Colors.blue,
                          icon: Icons.group_outlined,
                        ),
                        _SummaryChip(
                          label: 'Athletes',
                          value: _countByRole('athlete').toString(),
                          color: Colors.green,
                          icon: Icons.fitness_center_outlined,
                        ),
                        _SummaryChip(
                          label: 'Admins',
                          value: _countByRole('admin').toString(),
                          color: Colors.orange,
                          icon: Icons.admin_panel_settings_outlined,
                        ),
                        _SummaryChip(
                          label: 'Coaches',
                          value: _countByRole('coach').toString(),
                          color: Colors.purple,
                          icon: Icons.sports_outlined,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(_members.length, (index) {
                    final member = _members[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _members.length - 1 ? 0 : AppSpacing.md,
                      ),
                      child: AppCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MemberDetailScreen(
                                  name: member.fullName,
                                  email: member.email,
                                  role: member.role,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                child: Text(
                                  member.fullName.isNotEmpty
                                      ? member.fullName.characters.first.toUpperCase()
                                      : '?',
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.fullName,
                                      style: AppTextStyles.title,
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      member.email,
                                      style: AppTextStyles.caption,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    _RoleBadge(role: member.role),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({
    required this.role,
  });

  final String role;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (role) {
      case 'admin':
        color = Colors.orange;
        label = 'Admin';
        break;
      case 'coach':
        color = Colors.purple;
        label = 'Coach';
        break;
      case 'athlete':
      default:
        color = Colors.green;
        label = 'Athlete';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
