import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/auth/domain/auth_exception.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        setState(() => _emailSent = true);
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recoverPasswordTitle),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _emailSent
                  ? _SuccessView(email: _emailController.text.trim())
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.forgotPasswordLink,
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.forgotPasswordInstructions,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (!Env.hasSupabase)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text(l10n.supabaseNotConfigured),
                              ),
                            ),
                          if (_errorMessage != null) ...[
                            Text(
                              _errorMessage!,
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            const SizedBox(height: 16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: l10n.emailLabel,
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            enabled: !_isLoading && Env.hasSupabase,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.enterEmail;
                              }
                              if (!value.contains('@')) {
                                return l10n.invalidEmail;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _isLoading || !Env.hasSupabase
                                ? null
                                : _sendResetEmail,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.sendResetLink),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/auth/login'),
                            child: Text(l10n.backToSignIn),
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

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          l10n.emailSent,
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.resetEmailSentIfExists(email),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/auth/login'),
          child: Text(l10n.backToSignIn),
        ),
      ],
    );
  }
}
