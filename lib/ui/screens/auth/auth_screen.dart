import 'package:flutter/foundation.dart';
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
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final TextEditingController _serverUrlController;

  bool _isLoading = false;
  bool _showServerConfig = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _serverUrlController = TextEditingController(
      text: ref.read(authServiceProvider).serverUrl,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  Future<void> _applyServerUrlIfChanged() async {
    if (kIsWeb) return;
    final desired = _serverUrlController.text.trim();
    if (desired.isNotEmpty && desired != ref.read(authServiceProvider).serverUrl) {
      await ref.read(authProvider.notifier).updateServerUrl(desired);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _applyServerUrlIfChanged();
      await ref.read(authProvider.notifier).signIn(
            _emailController.text,
            _passwordController.text,
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInOAuth(String provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _applyServerUrlIfChanged();
      await ref.read(authProvider.notifier).signInWithOAuth2(provider);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showPasswordHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Password Help'),
        content: const Text(
          'Tasker uses invite-only accounts without automated email delivery.\n\n'
          '• Sign in with Google or Microsoft if your account email matches an invited user.\n'
          '• Otherwise, ask your administrator to reset your password in the PocketBase Admin UI (/_/).',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentServerUrl = ref.read(authServiceProvider).serverUrl;

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
                          const Flexible(
                            child: Column(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Invite-only banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_person_outlined, size: 16, color: AppColors.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Invite-only workspace. Accounts are provisioned by an admin in PocketBase (/_/).',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

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

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'you@example.com',
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
                        onFieldSubmitted: (_) => _isLoading ? null : _submit(),
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                        ),
                        validator: (val) {
                          if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showPasswordHelpDialog,
                          child: const Text('Need Help Signing In?', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email/Password Submit Button
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
                            : const Text('Sign In', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 18),

                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('or continue with', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ),
                          Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Google & Microsoft OAuth2 SSO Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.g_mobiledata, size: 20, color: Colors.blue),
                              label: const Text('Google', style: TextStyle(fontSize: 13)),
                              onPressed: _isLoading ? null : () => _signInOAuth('google'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.window, size: 16, color: Colors.cyan),
                              label: const Text('Microsoft', style: TextStyle(fontSize: 13)),
                              onPressed: _isLoading ? null : () => _signInOAuth('microsoft'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Server URL Config (Desktop / Mobile) or Web Origin info
                      if (!kIsWeb) ...[
                        TextButton.icon(
                          onPressed: () => setState(() => _showServerConfig = !_showServerConfig),
                          icon: Icon(_showServerConfig ? Icons.expand_less : Icons.dns_outlined, size: 15),
                          label: Text(
                            _showServerConfig ? 'Hide Server URL' : 'Server: $currentServerUrl',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ),
                        if (_showServerConfig) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _serverUrlController,
                            decoration: const InputDecoration(
                              labelText: 'Tasker Server URL',
                              hintText: 'https://1-2-3-4.sslip.io',
                              prefixIcon: Icon(Icons.cloud_outlined, size: 18),
                            ),
                            validator: (val) {
                              final trimmed = val?.trim() ?? '';
                              if (trimmed.isNotEmpty &&
                                  !trimmed.startsWith('http://') &&
                                  !trimmed.startsWith('https://')) {
                                return 'URL must start with https:// or http://';
                              }
                              return null;
                            },
                          ),
                        ],
                      ] else
                        Text(
                          'Connected to $currentServerUrl',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
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

