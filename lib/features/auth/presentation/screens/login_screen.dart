import 'package:flutter/material.dart';
import '../../../../app/routes/route_names.dart';
import '../../../../core/config/app_session.dart';
import '../../../../core/config/env.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../infra/auth/auth_repository.dart';
import '../../../gym_context/data/gym_context_repository_impl.dart';
import '../../../../shared/widgets/buttons/app_primary_button.dart';
import '../../../../shared/widgets/buttons/app_text_button.dart';
import '../../../../shared/widgets/cards/app_card.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/layout/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepository();
  final _gymContextRepository = GymContextRepositoryImpl();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (Env.isSupabaseConfigured) {
        debugPrint('LOGIN email=' + _emailController.text.trim());
        await _authRepository.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        await _gymContextRepository.acceptPendingInvitesForCurrentUser();

        AppSession.clear();
        AppSession.overrideEmail(_emailController.text.trim());
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 700));
      }

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        RouteNames.selectGym,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _emailController,
                  label: 'Email',
                  hintText: 'owner@ath615.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hintText: '••••••••',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: Env.isSupabaseConfigured ? 'Sign in' : 'Continue (mock)',
                  icon: Icons.arrow_forward,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextButton(
                  label: 'Create account',
                  onPressed: () {
                    Navigator.pushNamed(context, RouteNames.signUp);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
