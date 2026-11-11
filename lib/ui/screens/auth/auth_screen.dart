import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/auth_state.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isSignUp = false;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(text: 'admin@tasker.io');
  final _passwordController = TextEditingController(text: 'password123');
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isSignUp) {
        await ref.read(authProvider.notifier).signUp(
              _emailController.text,
              _passwordController.text,
              _nameController.text,
            );
      } else {
        await ref.read(authProvider.notifier).signIn(
              _emailController.text,
              _passwordController.text,
            );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _quickLogin(String email) {
    _emailController.text = email;
    _passwordController.text = 'password123';
    _submit();
  }

  void _showPasswordResetDialog() {
    final resetController = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your account email to receive a password recovery link.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetController,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref.read(authProvider.notifier).sendPasswordReset(resetController.text);
                if (ctx.mounted) nav.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Password reset instructions sent! Check your inbox.')),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Branding Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary, width: 1.5),
                            ),
                            child: const Icon(Icons.sync_alt, color: AppColors.primary, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tasker',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                'Tasks & Calendar Cloud Sync',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Sign In / Sign Up Mode Switcher
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !_isSignUp ? AppColors.surface : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontWeight: !_isSignUp ? FontWeight.bold : FontWeight.normal,
                                      color: !_isSignUp ? AppColors.textPrimary : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isSignUp = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _isSignUp ? AppColors.surface : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontWeight: _isSignUp ? FontWeight.bold : FontWeight.normal,
                                      color: _isSignUp ? AppColors.textPrimary : AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error Banner
                      if (_errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.overdue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.overdue.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppColors.overdue, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_errorMessage!, style: const TextStyle(fontSize: 12, color: AppColors.overdue)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Sign Up Display Name Field
                      if (_isSignUp) ...[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter your name';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || !val.contains('@')) return 'Enter a valid email address';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      // Forgot Password Link
                      if (!_isSignUp)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _showPasswordResetDialog,
                            child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Submit Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_isSignUp ? 'Create Account & Sync' : 'Sign In', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 24),

                      // Quick Demo Account Switcher
                      const Divider(color: AppColors.border),
                      const SizedBox(height: 12),
                      const Text(
                        'Quick Demo Login:',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.admin_panel_settings, size: 16, color: AppColors.primary),
                              label: const Text('Admin (Alex)', style: TextStyle(fontSize: 12)),
                              onPressed: () => _quickLogin('admin@tasker.io'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.person, size: 16, color: AppColors.inProgress),
                              label: const Text('User (Sarah)', style: TextStyle(fontSize: 12)),
                              onPressed: () => _quickLogin('sarah.chen@university.edu'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
