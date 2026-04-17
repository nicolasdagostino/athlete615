import 'package:flutter/material.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';
import '../../../gym_context/data/gym_context_repository_impl.dart';

class InviteAdminScreen extends StatefulWidget {
  const InviteAdminScreen({super.key});

  @override
  State<InviteAdminScreen> createState() => _InviteAdminScreenState();
}

class _InviteAdminScreenState extends State<InviteAdminScreen> {
  final _emailController = TextEditingController();
  final _repo = GymContextRepositoryImpl();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final gymId = AppSession.gymId;

    if (email.isEmpty || gymId == null) return;

    setState(() => _loading = true);

    try {
      await _repo.createInvite(
        gymId: gymId,
        email: email,
        role: 'admin',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin invite created')),
      );
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create invite: $error')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Invite admin',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _emailController,
                  label: 'Admin email',
                  hintText: 'admin@gym.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: 'Send invite',
                  isLoading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
