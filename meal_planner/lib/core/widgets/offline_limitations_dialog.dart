import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';

Future<void> showOfflineLimitationsDialog(
  BuildContext context, {
  required bool inHousehold,
}) {
  final l10n = context.l10n;
  final message = inHousehold
      ? l10n.offlineHouseholdMessage
      : l10n.offlineIndividualMessage;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.wifi_off),
      title: Text(l10n.offlineModeTitle),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.understood),
        ),
      ],
    ),
  );
}
