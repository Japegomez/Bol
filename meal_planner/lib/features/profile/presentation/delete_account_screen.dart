import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

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

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  bool _canSubmit(AppLocalizations l10n) {
    return _acknowledged &&
        !_isDeleting &&
        _confirmController.text.trim().toUpperCase() ==
            deleteConfirmationWord(l10n);
  }

  Future<void> _deleteAccount() async {
    final l10n = context.l10n;
    if (!_canSubmit(l10n)) return;

    setState(() {
      _isDeleting = true;
      _error = null;
    });

    try {
      final authState = ref.read(authStateProvider).valueOrNull;
      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }
      final userId = authState.user.id;
      final localCache = ref.read(localCacheStoreProvider);
      final authRepository = ref.read(authRepositoryProvider);

      await authRepository.deleteAccount();
      await localCache.clearUserSyncState(userId);

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
    final l10n = context.l10n;
    if (!_canSubmit(l10n)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deletePermanently),
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
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final email = authState.maybeWhen(
      data: (value) => value is AuthAuthenticated ? value.user.email : null,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.deleteAccount),
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
            l10n.gdprRightToErasure,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.deleteAccountBulletsIntro,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          _Bullet(l10n.deleteBulletProfile),
          _Bullet(l10n.deleteBulletRecipes),
          _Bullet(l10n.deleteBulletPlans),
          _Bullet(l10n.deleteBulletMembership),
          const SizedBox(height: 16),
          Text(
            l10n.soleAdminWarning,
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
            title: Text(l10n.deleteAcknowledgement),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmController,
            enabled: !_isDeleting,
            decoration: InputDecoration(
              labelText: l10n.typeDeleteToConfirm,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
          ),
          if (email != null) ...[
            const SizedBox(height: 8),
            Text(
              l10n.accountEmail(email),
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
            onPressed: _canSubmit(l10n) ? _showFinalConfirm : null,
            child: _isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.deleteMyAccount),
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
