import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/widgets/password_text_field.dart';
import 'package:meal_planner/features/auth/domain/auth_exception.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_exception_l10n.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/auth/presentation/widgets/google_sign_in_web_button.dart';
import 'package:meal_planner/features/auth/presentation/widgets/turnstile_captcha.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canUseAppleSignIn =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> _runAuth(Future<void> Function() action) async {
    final l10n = context.l10n;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    ref.read(authOperationInProgressProvider.notifier).state = true;
    try {
      await action();
      // Native Google/Apple can leave authStateProvider out of sync if Supabase's
      // auth stream errored on a deeplink. Reconcile from the persisted session.
      await _ensureAuthStateVisible();
    } on AuthCancelledException {
      // User dismissed the provider sheet — no error banner.
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = localizedAuthException(e, l10n));
      }
    } catch (_) {
      // Don't surface raw exception details; show a generic message.
      if (mounted) setState(() => _errorMessage = l10n.genericErrorMessage);
    } finally {
      ref.read(authOperationInProgressProvider.notifier).state = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// If Supabase has a session but [authStateProvider] is not authenticated,
  /// rebuild the stream so GoRouter redirects into the app.
  Future<void> _ensureAuthStateVisible() async {
    final session = ref.read(authRepositoryProvider).currentSession;
    if (session == null) return;

    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth is AuthAuthenticated) return;

    ref.invalidate(authStateProvider);
    // Allow the new stream subscription to emit before GoRouter refreshes.
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    String? captchaToken;
    if (Env.hasTurnstile) {
      captchaToken = await showTurnstileChallenge(context);
      if (!mounted || captchaToken == null || captchaToken.isEmpty) return;
    }

    await _runAuth(() async {
      await ref
          .read(authRepositoryProvider)
          .signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            captchaToken: captchaToken,
          );
    });
  }

  Future<void> _signInWithGoogle() =>
      _runAuth(() => ref.read(authRepositoryProvider).signInWithGoogle());

  Future<void> _signInWithApple() =>
      _runAuth(() => ref.read(authRepositoryProvider).signInWithApple());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sessionExpired = ref
        .watch(authStateProvider)
        .maybeWhen(
          data: (state) => state is AuthUnauthenticated && state.sessionExpired,
          orElse: () => false,
        );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppBranding.displayName,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.loginTagline,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    if (sessionExpired) ...[
                      Card(
                        color: theme.colorScheme.secondaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l10n.sessionExpiredMessage,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (!Env.hasSupabase)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(l10n.supabaseNotConfigured),
                        ),
                      ),
                    if (Env.hasSupabase && !Env.hasTurnstile)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(l10n.turnstileNotConfigured),
                        ),
                      ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                    const SizedBox(height: 16),
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    PasswordTextField(
                      controller: _passwordController,
                      labelText: l10n.passwordLabel,
                      autofillHints: const [AutofillHints.password],
                      enabled: !_isLoading && Env.hasSupabase,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.enterPassword;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _isLoading || !Env.hasSupabase
                          ? null
                          : _signInWithEmail,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.signIn),
                    ),
                    if (Env.hasGoogleSignIn) ...[
                      const SizedBox(height: 12),
                      if (kIsWeb)
                        GoogleSignInWebButton(
                          enabled: !_isLoading && Env.hasSupabase,
                          onSignIn: (user) => _runAuth(
                            () => ref
                                .read(authRepositoryProvider)
                                .signInWithGoogleAccount(user),
                          ),
                        )
                      else
                        OutlinedButton.icon(
                          onPressed: _isLoading || !Env.hasSupabase
                              ? null
                              : _signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: Text(l10n.continueWithGoogle),
                        ),
                    ],
                    if (_canUseAppleSignIn) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isLoading || !Env.hasSupabase
                            ? null
                            : _signInWithApple,
                        icon: const Icon(Icons.apple),
                        label: Text(l10n.continueWithApple),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => context.go('/auth/forgot-password'),
                        child: Text(l10n.forgotPasswordLink),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go('/auth/register'),
                      child: Text(l10n.noAccountRegister),
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
