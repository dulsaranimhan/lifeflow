import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import '../data/auth_providers.dart';
import 'auth_form_helpers.dart';
import 'widgets/auth_link_row.dart';

/// 02 – Login (S01).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(
            email: _emailController.text,
            password: _passwordController.text,
          );
      // The router redirects to /home once the auth state changes.
    } catch (error) {
      if (mounted) showAuthSnackBar(context, friendlyAuthMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _forgotPassword() {
    showAuthSnackBar(context, 'Password reset is coming soon.');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: AppLogo(),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      'Good to\nsee you again',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to get back to your flow and make today count.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/images/login_illustration.png',
                      height: 170,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      key: const Key('login_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: AuthValidators.email,
                      decoration: const InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      key: const Key('login_password'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _logIn(),
                      validator: AuthValidators.loginPassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.ink,
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _loading ? null : _logIn,
                      child: LoadingLabel(loading: _loading, label: 'Sign In'),
                    ),
                    const SizedBox(height: 12),
                    AuthLinkRow(
                      question: "Don't have an account?",
                      action: 'Create account',
                      onTap: _loading
                          ? null
                          : () => context.push(AppRoutes.register),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
