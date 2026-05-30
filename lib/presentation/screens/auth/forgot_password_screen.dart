import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/auth_submit_button.dart';
import '../../widgets/auth_text_field.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({this.initialEmail, super.key});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  Timer? _countdownTimer;
  DateTime? _cooldownExpiry;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.passwordResetEmailSent) {
        _startCooldown(next.passwordResetCooldownExpiry);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('password reset code and intructions are sent in ur email'),
          ),
        );
      }

      if (next.status == AuthStatus.failure && next.errorMessage != null) {
        if (next.passwordResetCooldownExpiry != null) {
          _startCooldown(next.passwordResetCooldownExpiry);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;
    final remainingSeconds = _remainingSeconds(authState.passwordResetCooldownExpiry);

    return AuthScaffold(
      title: 'Reset password',
      subtitle: 'Enter your email and we will send password reset instructions.',
      footer: TextButton(
        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        child: const Text('Back to sign in'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _emailController,
              label: 'Email',
              hintText: widget.initialEmail?.isNotEmpty == true
                  ? widget.initialEmail!
                  : 'info@educonnect.com',
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 28),
            AuthSubmitButton(
              label: remainingSeconds == null
                  ? 'Send email'
                  : 'Resend in ${_formatDuration(remainingSeconds)}',
              icon: Icons.mail_outline,
              isLoading: isLoading,
              onPressed: isLoading || remainingSeconds != null ? null : _submit,
            ),
            if (remainingSeconds != null) ...[
              const SizedBox(height: 10),
              Text(
                'You can request another reset code in ${_formatDuration(remainingSeconds)}.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ResetPasswordScreen(
                            initialEmail: _emailController.text,
                          ),
                        ),
                      );
                    },
              child: const Text('I have a reset code'),
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

    ref
        .read(authControllerProvider.notifier)
        .requestPasswordReset(_emailController.text);
  }

  void _startCooldown(DateTime? expiry) {
    if (expiry == null) return;
    _cooldownExpiry = expiry;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = _remainingSeconds(_cooldownExpiry);
      if (remaining == null) {
        timer.cancel();
        setState(() {
          _cooldownExpiry = null;
        });
        return;
      }

      setState(() {});
    });
    setState(() {});
  }

  int? _remainingSeconds(DateTime? expiry) {
    if (expiry == null) return null;

    final remaining = expiry.difference(DateTime.now()).inSeconds;
    if (remaining <= 0) {
      return null;
    }

    return remaining;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
