import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/feedback/app_loader.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/memberships_repository_impl.dart';
import '../../domain/models/membership_plan_summary.dart';
import 'create_plan_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _repo = MembershipsRepositoryImpl();

  bool _loading = true;
  List<MembershipPlanSummary> _plans = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plans = await _repo.listGymPlans();

    if (!mounted) return;

    setState(() {
      _plans = plans;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _load();
  }

  Future<void> _openCreatePlan() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const CreatePlanScreen(),
      ),
    );

    if (created == true) {
      await _load();
    }
  }

  Future<void> _openEditPlan(MembershipPlanSummary plan) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditPlanSheet(
        plan: plan,
        repo: _repo,
      ),
    );

    if (changed == true) {
      await _load();
    }
  }

  int _countByType(String type) {
    return _plans.where((plan) => plan.planType == type).length;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        title: 'Plans',
        child: AppLoader(label: 'Loading plans...'),
      );
    }

    return AppScaffold(
      title: 'Plans',
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePlan,
        child: const Icon(Icons.add),
      ),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: _plans.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No plans created yet'),
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
                          value: _plans.length.toString(),
                          color: Colors.blue,
                          icon: Icons.card_membership_outlined,
                        ),
                        _SummaryChip(
                          label: 'Packs',
                          value: _countByType('class_pack').toString(),
                          color: Colors.green,
                          icon: Icons.confirmation_number_outlined,
                        ),
                        _SummaryChip(
                          label: 'Drop-in',
                          value: _countByType('drop_in').toString(),
                          color: Colors.purple,
                          icon: Icons.flash_on_outlined,
                        ),
                        _SummaryChip(
                          label: 'Unlimited',
                          value: _countByType('unlimited').toString(),
                          color: Colors.orange,
                          icon: Icons.all_inclusive,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...List.generate(_plans.length, (index) {
                    final plan = _plans[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _plans.length - 1 ? 0 : AppSpacing.md,
                      ),
                      child: AppCard(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _openEditPlan(plan),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      plan.name,
                                      style: AppTextStyles.title,
                                    ),
                                  ),
                                  _TypeBadge(type: plan.planType),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                '${plan.priceLabel} · ${plan.ruleLabel}',
                                style: AppTextStyles.body,
                              ),
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

class _EditPlanSheet extends StatefulWidget {
  const _EditPlanSheet({
    required this.plan,
    required this.repo,
  });

  final MembershipPlanSummary plan;
  final MembershipsRepositoryImpl repo;

  @override
  State<_EditPlanSheet> createState() => _EditPlanSheetState();
}

class _EditPlanSheetState extends State<_EditPlanSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _creditsController;
  late final TextEditingController _priceController;

  late String _planType;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plan.name);
    _creditsController = TextEditingController(
      text: widget.plan.classesPerPeriod?.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.plan.price.truncateToDouble() == widget.plan.price
          ? widget.plan.price.toStringAsFixed(0)
          : widget.plan.price.toStringAsFixed(2),
    );
    _planType = widget.plan.planType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final name = _nameController.text.trim();
    final credits = int.tryParse(_creditsController.text.trim());
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty || price == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Complete required fields')),
      );
      return;
    }

    if (_planType == 'class_pack' && (credits == null || credits <= 0)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Add valid credits for this plan')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.repo.updatePlan(
        planId: widget.plan.id,
        name: name,
        planType: _planType,
        classesPerPeriod: _planType == 'drop_in'
            ? 1
            : _planType == 'class_pack'
                ? credits
                : null,
        price: price,
      );

      if (!mounted) return;
      navigator.pop(true);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not update plan: $error')),
      );
      setState(() => _saving = false);
    }
  }

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
            Text('Edit plan', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Plan name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              initialValue: _planType,
              decoration: const InputDecoration(
                labelText: 'Plan type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'class_pack', child: Text('Credits pack')),
                DropdownMenuItem(value: 'drop_in', child: Text('Drop-in')),
                DropdownMenuItem(value: 'unlimited', child: Text('Unlimited')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _planType = value);
                }
              },
            ),
            if (_planType == 'class_pack') ...[
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credits per month',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save changes'),
              ),
            ),
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

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.type,
  });

  final String type;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (type) {
      case 'unlimited':
        color = Colors.orange;
        label = 'Unlimited';
        break;
      case 'drop_in':
        color = Colors.purple;
        label = 'Drop-in';
        break;
      case 'class_pack':
        color = Colors.green;
        label = 'Credits pack';
        break;
      case 'weekly_limit':
        color = Colors.blue;
        label = 'Weekly limit';
        break;
      default:
        color = Colors.grey;
        label = type;
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
