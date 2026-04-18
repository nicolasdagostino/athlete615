import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../memberships/data/memberships_repository_impl.dart';
import '../../../memberships/domain/models/membership_plan_summary.dart';
import '../../data/admin_repository_impl.dart';
import '../../domain/models/admin_member_summary.dart';

class MemberDetailScreen extends StatefulWidget {
  const MemberDetailScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final _adminRepo = AdminRepositoryImpl();
  final _membershipsRepo = MembershipsRepositoryImpl();

  bool _loading = true;
  AdminMemberDetail? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final detail = await _adminRepo.getMemberDetail(widget.userId);

    if (!mounted) return;

    setState(() {
      _detail = detail;
      _loading = false;
    });
  }

  Future<void> _openAssignPlan() async {
    final plans = await _membershipsRepo.listGymPlans();
    if (!mounted) return;

    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AssignPlanSheet(
        userId: widget.userId,
        plans: plans,
        repo: _membershipsRepo,
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day/$month/$year';
  }

  String get _roleLabel {
    switch (_detail?.role) {
      case 'admin':
        return 'Admin';
      case 'coach':
        return 'Coach';
      case 'athlete':
      default:
        return 'Athlete';
    }
  }

  Color get _roleColor {
    switch (_detail?.role) {
      case 'admin':
        return Colors.orange;
      case 'coach':
        return Colors.purple;
      case 'athlete':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Member',
        child: AppLoader(label: 'Loading member...'),
      );
    }

    final detail = _detail;
    if (detail == null) {
      return const AppScaffold(
        title: 'Member',
        child: Center(child: Text('Member not found')),
      );
    }

    final initial = detail.fullName.trim().isNotEmpty
        ? detail.fullName.trim()[0].toUpperCase()
        : '?';

    final planLabel = detail.activePlanName ?? 'No active plan';
    final planSubtitle = detail.activePlanName == null
        ? 'Plan pending'
        : detail.activePlanType == 'credits'
            ? '${detail.activePlanCredits ?? 0} credits · valid for 1 month'
            : detail.activePlanType == 'unlimited'
                ? 'Unlimited · valid for 1 month'
                : detail.activePlanType == 'free'
                    ? 'Free/internal plan'
                    : 'Active plan';

    return AppScaffold(
      title: 'Member',
      child: ListView(
        children: [
          AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    initial,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(detail.fullName, style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _roleLabel,
                          style: AppTextStyles.caption.copyWith(
                            color: _roleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
                const Text('Contact', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(detail.email, style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Membership', style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.sm),
                Text(planLabel, style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.xs),
                Text(planSubtitle, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Start: ${_formatDate(detail.membershipStartDate)}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'End: ${_formatDate(detail.membershipEndDate)}',
                  style: AppTextStyles.caption,
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
                  leading: const Icon(Icons.card_membership_outlined),
                  title: const Text('Assign plan (cash)'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _openAssignPlan,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Send notification'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMessage(context, 'Send notification'),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit member'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showMessage(context, 'Edit member'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssignPlanSheet extends StatefulWidget {
  const _AssignPlanSheet({
    required this.userId,
    required this.plans,
    required this.repo,
  });

  final String userId;
  final List<MembershipPlanSummary> plans;
  final MembershipsRepositoryImpl repo;

  @override
  State<_AssignPlanSheet> createState() => _AssignPlanSheetState();
}

class _AssignPlanSheetState extends State<_AssignPlanSheet> {
  String? _selectedPlanId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Assign plan (cash)', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            if (widget.plans.isEmpty)
              const Text('No plans available')
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedPlanId,
                decoration: const InputDecoration(
                  labelText: 'Plan',
                  border: OutlineInputBorder(),
                ),
                items: widget.plans
                    .map(
                      (plan) => DropdownMenuItem(
                        value: plan.id,
                        child: Text('${plan.name} · ${plan.priceLabel}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedPlanId = value);
                },
              ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving || _selectedPlanId == null
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);

                        setState(() => _saving = true);
                        try {
                          await widget.repo.assignPlanCash(
                            userId: widget.userId,
                            planId: _selectedPlanId!,
                          );
                          if (!mounted) return;
                          navigator.pop(true);
                        } catch (error) {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(content: Text('Could not assign plan: $error')),
                          );
                          setState(() => _saving = false);
                        }
                      },
                child: Text(_saving ? 'Assigning...' : 'Assign plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
