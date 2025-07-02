// lib/screens/auth/login_screen.dart

import 'dart:ui';
import 'package:charmy_craft_studio/screens/auth/signup_screen.dart';
import 'package:charmy_craft_studio/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() { _isLoading = true; });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithEmail(
          _emailController.text.trim(), _passwordController.text.trim());

      if (!mounted) return;
      if (user == null) {
        _showErrorSnackbar('Invalid credentials. Please try again.');
      } else {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred: ${e.toString()}');
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  void _loginWithGoogle() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signInWithGoogle();
      if (mounted && user != null) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred during Google sign-in.');
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  // NEW: Forgot Password Dialog
  void _showForgotPasswordDialog() {
    final emailDialogController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Reset Password'),
            content: TextFormField(
              controller: emailDialogController,
              decoration: _buildInputDecoration('Enter your email', Icons.email_outlined),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final email = emailDialogController.text.trim();
                  if (email.isEmpty) return;

                  Navigator.of(context).pop(); // Close the dialog
                  final result = await ref.read(authServiceProvider).handlePasswordReset(email);

                  if(!mounted) return;

                  switch (result) {
                    case 'success':
                      _showSuccessSnackbar('Password reset link sent! Please check your email.');
                      break;
                    case 'google-sign-in':
                      _showErrorSnackbar('This account uses Google Sign-In. Please log in with Google.');
                      break;
                    case 'not-found':
                      _showSuccessSnackbar('If an account exists, a reset link has been sent.');
                      break;
                    default:
                      _showErrorSnackbar('An error occurred. Please try again.');
                  }
                },
                child: const Text('Send Link'),
              ),
            ],
          );
        }
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [const Color(0xFF1E1E1E), Colors.black]
                : [Colors.white, theme.colorScheme.secondary.withOpacity(0.1)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome Back!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                'Log in to continue your masterpiece.',
                style: GoogleFonts.lato(fontSize: 16, color: theme.textTheme.bodySmall?.color),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('Email Address', Icons.email_outlined),
                      validator: (value) => (value == null || !value.contains('@'))
                          ? 'Please enter a valid email'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _buildInputDecoration('Password', Icons.lock_outline),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Please enter a password'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _showForgotPasswordDialog, // NEW: Trigger for dialog
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: theme.colorScheme.secondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: _buildButtonStyle(theme.colorScheme.secondary),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('Login', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Sign in with Google'),
                        onPressed: _isLoading ? null : _loginWithGoogle,
                        style: _buildButtonStyle(theme.cardColor, isOutlined: true, theme: theme),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(begin: 0.2),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SignUpScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?", style: TextStyle(color: theme.textTheme.bodySmall?.color)),
                    const SizedBox(width: 8),
                    Text("Sign Up", style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.secondary.withOpacity(0.7)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 2),
      ),
    );
  }

  ButtonStyle _buildButtonStyle(Color backgroundColor, {bool isOutlined = false, ThemeData? theme}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? null : backgroundColor,
      foregroundColor: isOutlined ? theme?.textTheme.bodyLarge?.color : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      side: isOutlined ? BorderSide(color: theme?.dividerColor ?? Colors.grey.shade300) : null,
    );
  }
}