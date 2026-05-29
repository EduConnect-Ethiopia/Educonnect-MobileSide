import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_submit_button.dart';
import '../../widgets/auth_text_field.dart';
import '../main_navigation_screen.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({
    required this.email,
    this.password,
    this.autoRequest = true,
    super.key,
  });

  final String email;
  final String? password;
  final bool autoRequest;

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email);

    if (widget.autoRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(authControllerProvider.notifier)
            .requestEmailVerification(_emailController.text);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (next.status == AuthStatus.emailVerificationCodeSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent.')),
        );
      }

      if (next.status == AuthStatus.emailVerified) {
        if (widget.password != null && widget.password!.isNotEmpty) {
          await ref
              .read(authControllerProvider.notifier)
              .signIn(email: _emailController.text, password: widget.password!);
          return;
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email verified successfully.')),
        );
      }

      if (next.status == AuthStatus.authenticated) {
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const MainNavigationScreen(),
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

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return AuthScaffold(
      title: 'Verify your email',
      subtitle: 'Check your inbox for a verification code to continue.',
      footer: TextButton(
        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Back'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hintText: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.email,
            ),
            const SizedBox(height: 18),
            AuthTextField(
              controller: _codeController,
              label: 'Verification code',
              hintText: 'Enter the code from your email',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Verification code is required';
                }
                return null;
              },
              onFieldSubmitted: (_) => _confirm(),
            ),
            const SizedBox(height: 28),
            AuthSubmitButton(
              label: 'Confirm verification',
              icon: Icons.verified_outlined,
              isLoading: isLoading,
              onPressed: _confirm,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      ref
                          .read(authControllerProvider.notifier)
                          .resendEmailVerification(_emailController.text);
                    },
              child: const Text('Resend code'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    ref.read(authControllerProvider.notifier).confirmEmailVerification(
          email: _emailController.text,
          code: _codeController.text,
        );
  }
}
