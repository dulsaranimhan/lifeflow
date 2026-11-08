import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Field validators shared by the login and register forms.
abstract final class AuthValidators {
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Please enter your email';
    if (!_emailPattern.hasMatch(email)) return 'Please enter a valid email';
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please choose a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }
}

/// Turns an auth error into a message suitable for end users.
String friendlyAuthMessage(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email address, then log in.';
    }
    if (message.contains('already registered') ||
        message.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (message.contains('password')) {
      return error.message;
    }
    return 'Something went wrong: ${error.message}';
  }
  return 'Could not reach the server. Check your connection and try again.';
}

void showAuthSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

/// Button child that swaps its label for a spinner while [loading].
class LoadingLabel extends StatelessWidget {
  const LoadingLabel({super.key, required this.loading, required this.label});

  final bool loading;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (!loading) return Text(label);
    return const SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}
