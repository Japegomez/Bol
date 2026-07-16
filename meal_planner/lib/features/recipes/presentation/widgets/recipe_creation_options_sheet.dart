import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';

Future<String?> showRecipeCreationOptionsSheet(BuildContext context) {
  final l10n = context.l10n;
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.createRecipeOptionsTitle,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(l10n.createRecipeManual),
                subtitle: Text(l10n.createRecipeManualSubtitle),
                onTap: () => Navigator.pop(sheetContext, 'manual'),
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(l10n.createRecipeWithAssistant),
                subtitle: Text(l10n.createRecipeWithAssistantSubtitle),
                onTap: () => Navigator.pop(sheetContext, 'assistant'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
