import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../data/memberships_repository_impl.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final _nameController = TextEditingController();
  final _creditsController = TextEditingController();
  final _priceController = TextEditingController();
  final _repo = MembershipsRepositoryImpl();

  bool _loading = false;
  String _planType = 'class_pack';

  @override
  void dispose() {
    _nameController.dispose();
    _creditsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final credits = int.tryParse(_creditsController.text.trim());
    final price = double.tryParse(_priceController.text.trim());

    if (name.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete required fields')),
      );
      return;
    }

    if (_planType == 'class_pack' && (credits == null || credits <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add valid credits for this plan')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _repo.createPlan(
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
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create plan: $error')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create plan',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(
            shrinkWrap: true,
            children: [
              AppCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      controller: _nameController,
                      label: 'Plan name',
                      hintText: '8 Credits',
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
                      AppTextField(
                        controller: _creditsController,
                        label: 'Credits per month',
                        hintText: '8',
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _priceController,
                      label: 'Price',
                      hintText: '70',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: 'Create plan',
                      isLoading: _loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
