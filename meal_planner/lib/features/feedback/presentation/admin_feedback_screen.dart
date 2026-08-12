import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/widgets/skeleton.dart';
import 'package:meal_planner/features/feedback/domain/user_feedback.dart';
import 'package:meal_planner/features/feedback/presentation/feedback_provider.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

class AdminFeedbackScreen extends ConsumerStatefulWidget {
  const AdminFeedbackScreen({super.key});

  @override
  ConsumerState<AdminFeedbackScreen> createState() =>
      _AdminFeedbackScreenState();
}

class _AdminFeedbackScreenState extends ConsumerState<AdminFeedbackScreen> {
  FeedbackCategory? _categoryFilter;
  FeedbackStatus? _statusFilter = FeedbackStatus.pending;
  String? _updatingId;

  AdminFeedbackFilters get _filters => AdminFeedbackFilters(
        category: _categoryFilter,
        status: _statusFilter,
      );

  String _categoryLabel(AppLocalizations l10n, FeedbackCategory category) {
    return switch (category) {
      FeedbackCategory.issue => l10n.feedbackCategoryIssue,
      FeedbackCategory.feature => l10n.feedbackCategoryFeature,
      FeedbackCategory.other => l10n.feedbackCategoryOther,
    };
  }

  String _statusLabel(AppLocalizations l10n, FeedbackStatus status) {
    return switch (status) {
      FeedbackStatus.pending => l10n.feedbackStatusPending,
      FeedbackStatus.resolved => l10n.feedbackStatusResolved,
      FeedbackStatus.ignored => l10n.feedbackStatusIgnored,
    };
  }

  Color _badgeBackground(BuildContext context, FeedbackCategory category) {
    final scheme = Theme.of(context).colorScheme;
    return switch (category) {
      FeedbackCategory.issue => scheme.errorContainer,
      FeedbackCategory.feature => scheme.primaryContainer,
      FeedbackCategory.other => scheme.surfaceContainerHighest,
    };
  }

  Color _badgeForeground(BuildContext context, FeedbackCategory category) {
    final scheme = Theme.of(context).colorScheme;
    return switch (category) {
      FeedbackCategory.issue => scheme.onErrorContainer,
      FeedbackCategory.feature => scheme.onPrimaryContainer,
      FeedbackCategory.other => scheme.onSurfaceVariant,
    };
  }

  Future<void> _setStatus(UserFeedback item, FeedbackStatus status) async {
    final l10n = context.l10n;
    setState(() => _updatingId = item.id);
    try {
      await ref.read(updateFeedbackStatusProvider.notifier).updateStatus(
            feedbackId: item.id,
            status: status,
          );
      if (!mounted) return;
      ref.invalidate(adminFeedbackListProvider(_filters));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == FeedbackStatus.resolved
                ? l10n.feedbackMarkedResolved
                : l10n.feedbackMarkedIgnored,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.feedbackStatusUpdateError)),
      );
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final feedbackAsync = ref.watch(adminFeedbackListProvider(_filters));
    final dateFormat =
        DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_Hm();
    final updating = ref.watch(updateFeedbackStatusProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminFeedbackTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.feedbackStatusFilter,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(l10n.feedbackFilterAll),
                      selected: _statusFilter == null,
                      onSelected: (_) => setState(() => _statusFilter = null),
                    ),
                    for (final status in FeedbackStatus.values)
                      FilterChip(
                        label: Text(_statusLabel(l10n, status)),
                        selected: _statusFilter == status,
                        onSelected: (_) =>
                            setState(() => _statusFilter = status),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.feedbackCategoryFilter,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: Text(l10n.feedbackFilterAll),
                      selected: _categoryFilter == null,
                      onSelected: (_) => setState(() => _categoryFilter = null),
                    ),
                    for (final category in FeedbackCategory.values)
                      FilterChip(
                        label: Text(_categoryLabel(l10n, category)),
                        selected: _categoryFilter == category,
                        onSelected: (_) =>
                            setState(() => _categoryFilter = category),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: feedbackAsync.when(
              loading: () => const SkeletonList(item: ListTileSkeleton()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.adminFeedbackLoadError,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () =>
                            ref.invalidate(adminFeedbackListProvider(_filters)),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.adminFeedbackEmpty,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminFeedbackListProvider(_filters));
                    await ref.read(adminFeedbackListProvider(_filters).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isUpdating = updating && _updatingId == item.id;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _badgeBackground(
                                              context,
                                              item.category,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            _categoryLabel(
                                              l10n,
                                              item.category,
                                            ),
                                            style: theme
                                                .textTheme.labelMedium
                                                ?.copyWith(
                                              color: _badgeForeground(
                                                context,
                                                item.category,
                                              ),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        if (item.status !=
                                            FeedbackStatus.pending)
                                          Text(
                                            _statusLabel(l10n, item.status),
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.message,
                                      style: theme.textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      '${item.userDisplayName ?? l10n.defaultUsername}'
                                      ' · ${dateFormat.format(item.createdAt.toLocal())}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.status == FeedbackStatus.pending) ...[
                                const SizedBox(width: 8),
                                if (isUpdating)
                                  const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: l10n.feedbackMarkResolved,
                                        onPressed: updating
                                            ? null
                                            : () => _setStatus(
                                                  item,
                                                  FeedbackStatus.resolved,
                                                ),
                                        iconSize: 32,
                                        style: IconButton.styleFrom(
                                          foregroundColor:
                                              theme.colorScheme.primary,
                                          minimumSize: const Size(48, 48),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: const Icon(Icons.check),
                                      ),
                                      IconButton(
                                        tooltip: l10n.feedbackMarkIgnored,
                                        onPressed: updating
                                            ? null
                                            : () => _setStatus(
                                                  item,
                                                  FeedbackStatus.ignored,
                                                ),
                                        iconSize: 32,
                                        style: IconButton.styleFrom(
                                          foregroundColor:
                                              theme.colorScheme.primary,
                                          minimumSize: const Size(48, 48),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        icon: const Icon(Icons.close),
                                      ),
                                    ],
                                  ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
