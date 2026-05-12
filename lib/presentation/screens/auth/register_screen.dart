import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_submit_button.dart';
import '../../widgets/auth_text_field.dart';
import '../home/learner_home_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const LearnerHomeScreen(),
          ),
          (_) => false,
        );
      }

      if (next.status == AuthStatus.failure && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final isLoading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;

    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Join EduConnect as a learner',
      footer: TextButton(
        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Already have an account? Sign in'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _fullNameController,
              label: 'Full name',
              hintText: 'Abebe Bekele',
              validator: Validators.fullName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'abebe@duck.com',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _passwordController,
              label: 'Password',
              hintText: 'At least 8 characters',
              obscureText: true,
              showVisibilityToggle: true,
              validator: Validators.password,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 18),
            const _LearnerRoleSelector(),
            const SizedBox(height: 28),
            AuthSubmitButton(
              label: 'Create account',
              icon: Icons.person_add_alt_1_outlined,
              isLoading: isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref.read(authControllerProvider.notifier).register(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}

class _LearnerRoleSelector extends StatelessWidget {
  const _LearnerRoleSelector();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textHeadline,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.primary),
          ),
          child: Row(
            children: [
              const Icon(Icons.school_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                'Learner',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHeadline,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}
