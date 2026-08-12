import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/widgets/skeleton.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/domain/household_member_info.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:share_plus/share_plus.dart';

class HouseholdScreen extends ConsumerWidget {
  const HouseholdScreen({super.key});

  Future<void> _copyInviteCode(BuildContext context, String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.inviteCodeCopied)),
      );
    }
  }

  Future<void> _shareInviteViaWhatsApp(
    BuildContext context, {
    required String code,
  }) async {
    final l10n = context.l10n;
    final url = ShareUrls.householdInviteLink(code);
    final text = l10n.inviteWhatsAppHouseholdMessage(
      AppBranding.displayName,
      url,
    );
    final renderObject = context.findRenderObject();
    final origin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : const Rect.fromLTWH(0, 0, 1, 1);
    await Share.share(text, sharePositionOrigin: origin);
  }

  Future<void> _confirmRegenerateCode(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.regenerateCodeTitle),
        content: Text(l10n.regenerateCodeMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.regenerate),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(currentHouseholdProvider.notifier).regenerateCode();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.codeRegenerated)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _confirmKickMember(
    BuildContext context,
    WidgetRef ref,
    HouseholdMemberInfo member,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.kickMemberTitle),
        content: Text(l10n.kickMemberConfirm(member.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.kick),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final household = ref.read(currentHouseholdProvider).valueOrNull;
      await ref
          .read(currentHouseholdProvider.notifier)
          .kickMember(member.userId);
      if (household != null) {
        ref.invalidate(householdMembersByIdProvider(household.id));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _confirmLeaveHousehold(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveHouseholdTitle),
        content: Text(l10n.leaveHouseholdMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(currentHouseholdProvider.notifier).leave();
      if (context.mounted) context.pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final householdAsync = ref.watch(currentHouseholdProvider);
    final household = householdAsync.valueOrNull;

    if (householdAsync.isLoading && household == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myHouseholdTitle)),
        body: const HouseholdSkeleton(),
      );
    }

    if (household == null) {
      return _NoHouseholdView(
        onCreate: () => context.push('/home/profile/household/create'),
        onJoin: () => context.push('/home/profile/household/join'),
      );
    }

    final membersAsync = ref.watch(householdMembersByIdProvider(household.id));
    final roleAsync = ref.watch(currentUserHouseholdRoleProvider);
    final isAdmin = roleAsync.valueOrNull == 'admin';

    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.maybeWhen(
      data: (value) => value is AuthAuthenticated ? value.user.id : null,
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myHouseholdTitle),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(currentHouseholdProvider.notifier).refresh();
          ref.invalidate(householdMembersByIdProvider(household.id));
          ref.invalidate(currentUserHouseholdRoleProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              household.name,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.inviteCode,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        household.inviteCode,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.copyTooltip,
                      onPressed: () =>
                          _copyInviteCode(context, household.inviteCode),
                      icon: const Icon(Icons.copy),
                    ),
                    if (isAdmin)
                      IconButton(
                        tooltip: l10n.regenerate,
                        onPressed: () =>
                            _confirmRegenerateCode(context, ref),
                        icon: const Icon(Icons.refresh),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Builder(
              builder: (buttonContext) => FilledButton.tonalIcon(
                onPressed: () => _shareInviteViaWhatsApp(
                  buttonContext,
                  code: household.inviteCode,
                ),
                icon: const Icon(Icons.chat_outlined),
                label: Text(l10n.inviteViaWhatsApp),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.members,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            membersAsync.when(
              loading: () => const ExcludeSemantics(
                child: SkeletonPulse(
                  child: Column(
                    children: [
                      ListTileSkeleton(),
                      ListTileSkeleton(),
                      ListTileSkeleton(),
                    ],
                  ),
                ),
              ),
              error: (error, _) => Text(
                error.toString(),
                style: TextStyle(color: theme.colorScheme.error),
              ),
              data: (members) => Column(
                children: members
                    .map(
                      (member) => _MemberTile(
                        member: member,
                        isCurrentUser: member.userId == currentUserId,
                        canKick: isAdmin &&
                            member.userId != currentUserId &&
                            !member.isAdmin,
                        onKick: () =>
                            _confirmKickMember(context, ref, member),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => _confirmLeaveHousehold(context, ref),
              icon: const Icon(Icons.exit_to_app),
              label: Text(l10n.leaveHousehold),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoHouseholdView extends StatelessWidget {
  const _NoHouseholdView({
    required this.onCreate,
    required this.onJoin,
  });

  final VoidCallback onCreate;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myHouseholdTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.home_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noSharedHousehold,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.individualModeDescription,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: Text(l10n.createHousehold),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onJoin,
              icon: const Icon(Icons.group_add_outlined),
              label: Text(l10n.joinWithCode),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.member,
    required this.isCurrentUser,
    required this.canKick,
    required this.onKick,
  });

  final HouseholdMemberInfo member;
  final bool isCurrentUser;
  final bool canKick;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: member.avatarUrl != null
              ? CachedNetworkImageProvider(member.avatarUrl!)
              : null,
          child: member.avatarUrl == null
              ? Text(
                  member.username.isNotEmpty
                      ? member.username[0].toUpperCase()
                      : '?',
                )
              : null,
        ),
        title: Text(
          isCurrentUser
              ? l10n.currentUserSuffix(member.username)
              : member.username,
        ),
        subtitle: Text(member.isAdmin ? l10n.admin : l10n.member),
        trailing: canKick
            ? IconButton(
                tooltip: l10n.kick,
                onPressed: onKick,
                icon: Icon(
                  Icons.person_remove_outlined,
                  color: theme.colorScheme.error,
                ),
              )
            : null,
      ),
    );
  }
}
