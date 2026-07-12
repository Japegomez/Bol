import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/theme/theme_mode_provider.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:meal_planner/features/profile/presentation/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return;

    final userId = authState.user.id;
    await ref.read(authRepositoryProvider).signOut(manual: true);
    await ref.read(localCacheStoreProvider).clearUserSyncState(userId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(profileProvider);
    final householdAsync = ref.watch(currentHouseholdProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    final user = authState.maybeWhen(
      data: (value) => value is AuthAuthenticated ? value.user : null,
      orElse: () => null,
    );

    final profile = profileAsync.valueOrNull;
    final username = profile?.username ??
        user?.userMetadata?['username'] as String? ??
        'Usuario';
    final email = user?.email;
    final avatarUrl = profile?.avatarUrl;
    final household = householdAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: profileAsync.isLoading && profile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: avatarUrl != null
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Icon(
                            Icons.person,
                            size: 48,
                            color: theme.colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                if (email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 16),
                Center(
                  child: Chip(
                    avatar: Icon(
                      household != null ? Icons.home : Icons.person_outline,
                      size: 18,
                    ),
                    label: Text(
                      household?.name ?? 'Modo individual (sin hogar)',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Modo oscuro'),
                    value: isDarkMode,
                    onChanged: (enabled) =>
                        ref.read(themeModeProvider.notifier).setDarkMode(enabled),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_outlined),
                        title: const Text('Editar perfil'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/home/profile/edit'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.home_outlined),
                        title: const Text('Mi hogar'),
                        subtitle: Text(
                          household != null
                              ? household.name
                              : 'Crear o unirse a un hogar',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/home/profile/household'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: const Text('Términos y Condiciones'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/legal/terms'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Política de Privacidad'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/legal/privacy'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: user == null
                      ? null
                      : () => _confirmSignOut(context, ref),
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: user == null
                      ? null
                      : () => context.push('/home/profile/delete-account'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: const Text('Eliminar cuenta'),
                ),
                if (profileAsync.hasError) ...[
                  const SizedBox(height: 16),
                  Text(
                    profileAsync.error.toString(),
                    style: TextStyle(color: theme.colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
    );
  }
}
