import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/moderation/photo_moderation_service.dart';

Future<bool> moderatePickedImage({
  required BuildContext context,
  required WidgetRef ref,
  required Uint8List bytes,
  void Function(String message)? onServiceError,
}) async {
  final l10n = context.l10n;

  try {
    final service = ref.read(photoModerationServiceProvider);
    final result = await service.check(bytes);
    if (!context.mounted) return false;

    if (!result.allowed) {
      await showImageRejectedDialog(context);
      return false;
    }

    return true;
  } on PhotoModerationException catch (e) {
    if (onServiceError != null) {
      onServiceError(e.message);
    } else if (context.mounted) {
      await showImageModerationErrorDialog(context, e.message);
    }
    return false;
  } catch (_) {
    final message = l10n.imageCheckFailedRetry;
    if (onServiceError != null) {
      onServiceError(message);
    } else if (context.mounted) {
      await showImageModerationErrorDialog(context, message);
    }
    return false;
  }
}

Future<void> showImageRejectedDialog(BuildContext context) {
  final l10n = context.l10n;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.imageNotAllowedTitle),
      content: Text(l10n.imageNotAllowedMessage),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.understood),
        ),
      ],
    ),
  );
}

Future<void> showImageModerationErrorDialog(
  BuildContext context,
  String message,
) {
  final l10n = context.l10n;

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.imageCheckFailedTitle),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.understood),
        ),
      ],
    ),
  );
}
