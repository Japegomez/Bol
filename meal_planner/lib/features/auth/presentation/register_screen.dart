import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/widgets/password_text_field.dart';
import 'package:meal_planner/features/auth/domain/auth_exception.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _isLoading = false;
  bool _registrationSent = false;
  bool _acceptedTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = 'Debes aceptar los Términos y la Política de Privacidad';
      });
      return;
    }

    ref.read(authOperationInProgressProvider.notifier).state = true;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            username: _usernameController.text.trim(),
          );
      if (mounted) {
        setState(() => _registrationSent = true);
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      ref.read(authOperationInProgressProvider.notifier).state = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _registrationSent
                  ? _SuccessView(email: _emailController.text.trim())
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Regístrate en ${AppBranding.displayName}',
                            style: theme.textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (!Env.hasSupabase)
                            const Card(
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  'Supabase no configurado. Copia dart_defines.example.json '
                                  'a dart_defines.json y añade SUPABASE_URL / SUPABASE_ANON_KEY.',
                                ),
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
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de usuario',
                              border: OutlineInputBorder(),
                            ),
                            textCapitalization: TextCapitalization.words,
                            enabled: !_isLoading && Env.hasSupabase,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Introduce tu nombre de usuario';
                              }
                              if (value.trim().length < 2) {
                                return 'Mínimo 2 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            enabled: !_isLoading && Env.hasSupabase,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Introduce tu email';
                              }
                              if (!value.contains('@')) {
                                return 'Email no válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          PasswordTextField(
                            controller: _passwordController,
                            labelText: 'Contraseña',
                            autofillHints: const [AutofillHints.newPassword],
                            enabled: !_isLoading && Env.hasSupabase,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Introduce una contraseña';
                              }
                              if (value.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          PasswordTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Confirmar contraseña',
                            autofillHints: const [AutofillHints.newPassword],
                            enabled: !_isLoading && Env.hasSupabase,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          CheckboxListTile(
                            value: _acceptedTerms,
                            onChanged: _isLoading || !Env.hasSupabase
                                ? null
                                : (value) => setState(
                                      () => _acceptedTerms = value ?? false,
                                    ),
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text('Acepto los '),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => context.push('/legal/terms'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Términos'),
                                ),
                                const Text(' y la '),
                                TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => context.push('/legal/privacy'),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Política de Privacidad'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: _isLoading || !Env.hasSupabase
                                ? null
                                : _register,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Crear cuenta'),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _isLoading
                                ? null
                                : () => context.go('/auth/login'),
                            child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
          'Revisa tu email',
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Hemos enviado un enlace de confirmación a $email. '
          'Confirma tu cuenta antes de iniciar sesión.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => context.go('/auth/login'),
          child: const Text('Ir al inicio de sesión'),
        ),
      ],
    );
  }
}
