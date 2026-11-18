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
        title: const Text('Account access help'),
        content: const Text(
          'Tasker accounts are invite-only without automated email delivery.\n\n'
          'Sign in with Google or Microsoft if your email matches an invited account, or ask your workspace admin to reset your password in PocketBase (/_/).',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentServerUrl = ref.read(authServiceProvider).serverUrl;
    final compact = MediaQuery.of(context).size.width < 520;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: EdgeInsets.all(compact ? 24 : 32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderStrong),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Flat branding header
                    Row(
                      children: [
                        const TaskerMark(size: 32),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tasker',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Tasks, calendar prep, and cross-device sync',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Invite-only notice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Invite-only workspace provisioned in PocketBase (/_/)',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.overdue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.overdue.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.overdue, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(fontSize: 12, color: AppColors.overdue),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                      ),
                      validator: (val) {
                        if (val == null || !val.contains('@')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      onFieldSubmitted: (_) => _isLoading ? null : _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Password',
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
                        child: const Text(
                          'Account access help',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.actionFg,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 20),

                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or continue with',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                            icon: const Icon(Icons.account_circle_outlined, size: 16, color: AppColors.textSecondary),
                            label: const Text('Google'),
                            onPressed: _isLoading ? null : () => _signInOAuth('google'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                            icon: const Icon(Icons.grid_view_outlined, size: 16, color: AppColors.textSecondary),
                            label: const Text('Microsoft'),
                            onPressed: _isLoading ? null : () => _signInOAuth('microsoft'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (!kIsWeb) ...[
                      TextButton.icon(
                        onPressed: () => setState(() => _showServerConfig = !_showServerConfig),
                        icon: Icon(
                          _showServerConfig ? Icons.expand_less : Icons.dns_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        label: Text(
                          _showServerConfig ? 'Hide server URL' : 'Server: $currentServerUrl',
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.mono(11, color: AppColors.textMuted),
                        ),
                      ),
                      if (_showServerConfig) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _serverUrlController,
                          decoration: const InputDecoration(
                            labelText: 'Server URL',
                            hintText: 'https://1-2-3-4.sslip.io',
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
                        currentServerUrl,
                        textAlign: TextAlign.center,
                        style: AppTheme.mono(11, color: AppColors.textMuted),
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
