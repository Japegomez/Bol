import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/moderation/photo_moderation_service.dart';

Future<bool> moderatePickedImage({
  required BuildContext context,
  required WidgetRef ref,
  required Uint8List bytes,
  void Function(String message)? onServiceError,
}) async {
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
    const message = 'No se pudo comprobar la imagen. Inténtalo de nuevo.';
    if (onServiceError != null) {
      onServiceError(message);
    } else if (context.mounted) {
      await showImageModerationErrorDialog(context, message);
    }
    return false;
  }
}

Future<void> showImageRejectedDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Imagen no permitida'),
      content: const Text(
        'La imagen seleccionada contiene contenido adulto o explícito '
        'que no está permitido. Por favor, elige otra imagen.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}

Future<void> showImageModerationErrorDialog(
  BuildContext context,
  String message,
) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('No se pudo comprobar la imagen'),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
