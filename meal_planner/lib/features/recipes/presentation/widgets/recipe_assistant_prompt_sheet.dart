import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

String resolveRecipeAssistantError(String error, AppLocalizations l10n) {
  return switch (error) {
    recipeAssistantNotRecipeRequestKey => l10n.recipeAssistantNotRecipeRequest,
    recipeAssistantRateLimitedKey => l10n.recipeAssistantRateLimited,
    recipeAssistantDailyLimitKey => l10n.recipeAssistantDailyLimitReached,
    recipeAssistantTooFastKey => l10n.recipeAssistantTooFast,
    recipeAssistantServiceAtCapacityKey => l10n.recipeAssistantServiceAtCapacity,
    recipeAssistantOfflineKey => l10n.recipeAssistantOffline,
    recipeAssistantNotConfiguredKey => l10n.recipeAssistantNotConfigured,
    recipeAssistantTimeoutKey => l10n.recipeAssistantTimeout,
    _ => l10n.recipeAssistantFailed,
  };
}

/// Runs [task] while showing a full-screen modal that blocks all app interaction.
Future<T> runWithRecipeAssistantBlockingOverlay<T>({
  required BuildContext context,
  required String message,
  required Future<T> Function() task,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    useRootNavigator: true,
    pageBuilder: (dialogContext, _, _) => PopScope(
      canPop: false,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  try {
    return await task();
  } finally {
    if (navigator.mounted) {
      navigator.pop();
    }
  }
}

/// Returns the user's prompt, or `null` if the sheet was dismissed.
Future<String?> showRecipeAssistantPromptSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => const _RecipeAssistantPromptSheet(),
  );
}

class _RecipeAssistantPromptSheet extends ConsumerStatefulWidget {
  const _RecipeAssistantPromptSheet();

  @override
  ConsumerState<_RecipeAssistantPromptSheet> createState() =>
      _RecipeAssistantPromptSheetState();
}

class _RecipeAssistantPromptSheetState
    extends ConsumerState<_RecipeAssistantPromptSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;
    Navigator.pop(context, prompt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOffline = ref.watch(isOfflineProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.recipeAssistantTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.recipeAssistantDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !isOffline,
            maxLines: 5,
            minLines: 3,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l10n.recipeAssistantPromptHint,
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (isOffline) ...[
            const SizedBox(height: 8),
            Text(
              l10n.recipeAssistantOffline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isOffline || _controller.text.trim().isEmpty
                ? null
                : _submit,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.recipeAssistantGenerate),
          ),
        ],
      ),
    );
  }
}

Future<void> generateNutritionWithAssistant({
  required WidgetRef ref,
  required BuildContext context,
  required String title,
  required int servings,
  required List<IngredientFormItem> ingredients,
  required FutureOr<void> Function(NutritionFormData nutrition) onSuccess,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);

  NutritionFormData nutrition;
  try {
    nutrition = await runWithRecipeAssistantBlockingOverlay(
      context: context,
      message: l10n.recipeAssistantBlockingNutrition,
      task: () => ref.read(recipeAssistantRepositoryProvider).generateNutrition(
            title: title,
            servings: servings,
            ingredients: ingredients,
          ),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          resolveRecipeAssistantError(
            error.toString().replaceFirst('Exception: ', ''),
            l10n,
          ),
        ),
      ),
    );
    return;
  }

  try {
    await onSuccess(nutrition);
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          resolveRecipeAssistantError(
            error.toString().replaceFirst('Exception: ', ''),
            l10n,
          ),
        ),
      ),
    );
  }
}
