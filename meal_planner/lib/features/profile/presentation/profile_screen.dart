import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/local_db/local_db_provider.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/language_selector_tile.dart';
import 'package:meal_planner/core/review/review_prompt_service.dart';
import 'package:meal_planner/core/theme/theme_mode_provider.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_targets.dart';
import 'package:meal_planner/features/profile/presentation/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _rateApp(BuildContext context) async {
    final l10n = context.l10n;
    final opened = await ReviewPromptService.openRateApp();
    if (!context.mounted || opened) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.rateAppUnavailable)),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.signOutTitle),
        content: Text(l10n.signOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return;

    final userId = authState.user.id;
    final localCache = ref.read(localCacheStoreProvider);
    final authRepository = ref.read(authRepositoryProvider);

    try {
      await localCache.clearUserSyncState(userId);
    } catch (_) {
      // Continue with sign-out even if local cleanup fails
    }
    await authRepository.signOut(manual: true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
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
        l10n.defaultUsername;
    final email = user?.email;
    final avatarUrl = profile?.avatarUrl;
    final household = householdAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
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
                      household?.name ?? l10n.individualModeNoHousehold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      const LanguageSelectorTile(),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.dark_mode_outlined),
                        title: Text(l10n.darkMode),
                        value: isDarkMode,
                        onChanged: (enabled) => ref
                            .read(themeModeProvider.notifier)
                            .setDarkMode(enabled),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        key: OnboardingTargets.keyFor(
                          OnboardingTarget.profileEditTile,
                        ),
                        leading: const Icon(Icons.edit_outlined),
                        title: Text(l10n.editProfile),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/home/profile/edit'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        key: OnboardingTargets.keyFor(
                          OnboardingTarget.profileHouseholdTile,
                        ),
                        leading: const Icon(Icons.home_outlined),
                        title: Text(l10n.myHousehold),
                        subtitle: Text(
                          household != null
                              ? household.name
                              : l10n.createOrJoinHousehold,
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
                        title: Text(l10n.termsAndConditions),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/legal/terms'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: Text(l10n.privacyPolicy),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/legal/privacy'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.star_outline),
                        title: Text(l10n.rateYourApp),
                        subtitle: Text(l10n.rateYourAppSubtitle),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _rateApp(context),
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
                  label: Text(l10n.signOut),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: user == null
                      ? null
                      : () => context.push('/home/profile/delete-account'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  child: Text(l10n.deleteAccount),
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
