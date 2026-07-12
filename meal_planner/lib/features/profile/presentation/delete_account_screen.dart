import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _confirmController = TextEditingController();
  var _acknowledged = false;
  var _isDeleting = false;
  String? _error;

  static const _confirmWord = 'ELIMINAR';

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _acknowledged &&
        !_isDeleting &&
        _confirmController.text.trim().toUpperCase() == _confirmWord;
  }

  Future<void> _deleteAccount() async {
    if (!_canSubmit) return;

    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      final authState = ref.read(authStateProvider).valueOrNull;
      if (authState is AuthAuthenticated) {
        await ref
            .read(localCacheStoreProvider)
            .clearUserSyncState(authState.user.id);
      }
      await ref.read(authRepositoryProvider).deleteAccount();
      if (!mounted) return;
      context.go('/auth/login');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _showFinalConfirm() async {
    if (!_canSubmit) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar cuenta?'),
        content: const Text(
          'Esta acción es permanente. Se borrarán tu perfil, recetas, '
          'planificador personal y listas asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final email = authState.maybeWhen(
      data: (value) => value is AuthAuthenticated ? value.user.email : null,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eliminar cuenta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Derecho de supresión (RGPD)',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            'Al eliminar tu cuenta se borrarán de forma permanente:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          const _Bullet('Tu perfil y avatar'),
          const _Bullet('Todas tus recetas e imágenes asociadas'),
          const _Bullet('Tus planes y listas de la compra en modo individual'),
          const _Bullet('Tu membresía en hogares compartidos'),
          const SizedBox(height: 16),
          Text(
            'Si eres el único administrador de un hogar con otros miembros, '
            'debes transferir el rol de administrador o pedir a los miembros '
            'que abandonen el hogar antes de eliminar la cuenta.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: _acknowledged,
            onChanged: _isDeleting
                ? null
                : (value) => setState(() => _acknowledged = value ?? false),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'Entiendo que esta acción es irreversible y deseo eliminar mi cuenta.',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            enabled: !_isDeleting,
            decoration: const InputDecoration(
              labelText: 'Escribe ELIMINAR para confirmar',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
          ),
          if (email != null) ...[
            const SizedBox(height: 8),
            Text(
              'Cuenta: $email',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: _canSubmit ? _showFinalConfirm : null,
            child: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Eliminar mi cuenta'),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
