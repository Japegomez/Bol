import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_session_provider.dart';

/// Formats a [Duration] as MM:SS or H:MM:SS.
String formatCookingDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

/// Shows the "finish cooking?" confirmation dialog and calls [notifier.finish]
/// if the user confirms.
Future<void> confirmFinishCooking(
  BuildContext context,
  CookingSessionNotifier notifier,
) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.finishCookingTitle),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.finishCookingButton),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await notifier.finish();
  }
}
