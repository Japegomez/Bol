import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/locale_provider.dart';
import 'package:meal_planner/core/locale/supported_locales.dart';

class LanguageSelectorTile extends ConsumerWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);
    final currentCode = currentLocale?.languageCode ??
        Localizations.localeOf(context).languageCode;

    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: Text(l10n.languageTitle),
      subtitle: Text(
        currentLocale == null
            ? l10n.languageSystemDefault
            : displayNameForLanguageCode(currentCode),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showLanguagePicker(context, ref),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context, WidgetRef ref) async {
    final currentLocale = ref.read(localeProvider);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final l10n = sheetContext.l10n;
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.85;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(l10n.languageSystemDefault),
                    trailing: currentLocale == null
                        ? Icon(
                            Icons.check,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          )
                        : null,
                    onTap: () async {
                      await ref.read(localeProvider.notifier).setLocale(null);
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                    },
                  ),
                  for (final locale in supportedAppLocales)
                    ListTile(
                      title:
                          Text(displayNameForLanguageCode(locale.languageCode)),
                      trailing:
                          currentLocale?.languageCode == locale.languageCode
                              ? Icon(
                                  Icons.check,
                                  color:
                                      Theme.of(sheetContext).colorScheme.primary,
                                )
                              : null,
                      onTap: () async {
                        await ref
                            .read(localeProvider.notifier)
                            .setLocale(locale);
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
