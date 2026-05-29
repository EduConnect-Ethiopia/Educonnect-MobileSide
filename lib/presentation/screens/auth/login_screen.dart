import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/auth_submit_button.dart';
import '../../widgets/auth_text_field.dart';
import '../main_navigation_screen.dart';
import 'email_verification_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const MainNavigationScreen()),
          (_) => false,
        );
      }

      if (next.status == AuthStatus.emailVerificationRequired &&
          previous?.status != AuthStatus.emailVerificationRequired) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => EmailVerificationScreen(
              email: next.pendingEmail ?? _emailController.text,
              password: next.pendingPassword ?? _passwordController.text,
            ),
          ),
        );
      }

      if (next.status == AuthStatus.failure && next.errorMessage != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 19.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 50.w,
                          height: 50.w,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.link,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      SizedBox(height: 176.h),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Please enter your details to sign in',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF333333),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 33.h),
                      AuthTextField(
                        controller: _emailController,
                        label: 'Email',
                        hintText: 'educonnect@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                      ),
                      SizedBox(height: 16.h),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: '************',
                        obscureText: true,
                        validator: Validators.password,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      SizedBox(height: 32.h),
                      AuthSubmitButton(
                        label: 'Sign in',
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                      SizedBox(height: 120.h),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text("Don't have an account? Sign up"),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }
}
