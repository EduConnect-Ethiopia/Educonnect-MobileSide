import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/validators.dart';
import '../../providers/auth_controller.dart';
import '../../widgets/auth_submit_button.dart';
import '../../widgets/auth_text_field.dart';
import 'email_verification_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final isLoading =
        ref.watch(authControllerProvider).status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                          fontSize: 20.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Join EduConnect and start learning',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF333333),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      AuthTextField(
                        controller: _fullNameController,
                        label: 'Full Name',
                        hintText: 'Your full name',
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
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
                        controller: _phoneController,
                        label: 'Phone Number (Optional)',
                        hintText: '+251 9XX XXX XXXX',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      AuthTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hintText: '••••••••',
                        obscureText: true,
                        validator: Validators.password,
                        textInputAction: TextInputAction.next,
                      ),
                      SizedBox(height: 16.h),
                      AuthTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hintText: '••••••••',
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Confirm password is required';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (value) {
                              setState(() {
                                _agreeToTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 11.sp,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      AuthSubmitButton(
                        label: 'Sign up',
                        isLoading: isLoading,
                        onPressed: () => _submit(ref),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? '),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
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

  void _submit(WidgetRef ref) {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(authControllerProvider.notifier).register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }
}
