import 'package:flutter/material.dart';
import 'dart:async';
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
    this.autoRequest = false,
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
    _remainingSeconds = 0;
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
        return;
      }

      if (next.status == AuthStatus.emailVerificationCodeSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent.')),
        );
      }

      _updateCooldownFromState(next.verificationCooldownExpiry);

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
      subtitle:
          'Enter the verification code sent to the email you just used to log in.',
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
              hintText:
                  'Enter the verification code sent to your email',
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
              label: 'Verify',
              icon: Icons.verified_outlined,
              isLoading: isLoading,
              onPressed: _confirm,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: (isLoading || _remainingSeconds > 0)
                  ? null
                  : () {
                      ref
                          .read(authControllerProvider.notifier)
                          .resendEmailVerification(_emailController.text);
                    },
                child: Text(_remainingSeconds > 0
                  ? 'Resend code (${_formatRemaining(_remainingSeconds)})'
                  : 'Resend code'),
            ),
          ],
        ),
      ),
    );
  }

  Timer? _cooldownTimer;
  int _remainingSeconds = 0;

  void _updateCooldownFromState(DateTime? expiry) {
    _cooldownTimer?.cancel();
    if (expiry == null) {
      if (_remainingSeconds != 0) {
        setState(() => _remainingSeconds = 0);
      }
      return;
    }

    final now = DateTime.now();
    var secs = expiry.difference(now).inSeconds;
    if (secs <= 0) {
      setState(() => _remainingSeconds = 0);
      return;
    }

    setState(() => _remainingSeconds = secs);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = expiry.difference(DateTime.now()).inSeconds;
      if (remaining <= 0) {
        timer.cancel();
        if (mounted) setState(() => _remainingSeconds = 0);
        return;
      }
      if (mounted) setState(() => _remainingSeconds = remaining);
    });
  }

  String _formatRemaining(int seconds) {
    if (seconds <= 0) return '0s';
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = secs.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final auth = ref.read(authControllerProvider.notifier);
    final verified = await auth.confirmEmailVerification(
          email: _emailController.text,
          code: _codeController.text,
        );

    if (!verified || !mounted) {
      return;
    }

    if (widget.password != null && widget.password!.isNotEmpty) {
      await auth.signIn(
        email: _emailController.text,
        password: widget.password!,
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email verified successfully.')),
    );
  }
}
