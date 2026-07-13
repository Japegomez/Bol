import 'package:flutter/material.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

class TranslationStatusBanner extends StatelessWidget {
  const TranslationStatusBanner({
    required this.l10n,
    required this.isTranslated,
    required this.translationFailed,
    required this.showingOriginal,
    required this.onToggleOriginal,
    super.key,
  });

  final AppLocalizations l10n;
  final bool isTranslated;
  final bool translationFailed;
  final bool showingOriginal;
  final VoidCallback? onToggleOriginal;

  @override
  Widget build(BuildContext context) {
    if (isTranslated) {
      return Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.translate,
                size: 18,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.autoTranslatedBadge,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                ),
              ),
              TextButton(
                onPressed: onToggleOriginal,
                child: Text(
                  showingOriginal ? l10n.viewTranslation : l10n.viewOriginal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (translationFailed) {
      return Text(
        l10n.translationFailed,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }

    return const SizedBox.shrink();
  }
}
