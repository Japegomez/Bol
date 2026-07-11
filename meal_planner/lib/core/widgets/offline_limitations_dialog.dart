import 'package:flutter/material.dart';

Future<void> showOfflineLimitationsDialog(
  BuildContext context, {
  required bool inHousehold,
}) {
  final message = inHousehold
      ? 'Estás sin conexión. Puedes consultar la última versión guardada de '
          'tu recetario, planificador y lista de la compra, pero la edición '
          'no está disponible en modo hogar sin conexión (para evitar '
          'conflictos con otros miembros). Explorar tampoco está disponible.'
      : 'Estás sin conexión. Puedes consultar y editar tu recetario, '
          'planificador y lista de la compra; los cambios se sincronizarán '
          'al recuperar la conexión. La foto de recetas y la pestaña Explorar '
          'no están disponibles sin conexión.';

  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.wifi_off),
      title: const Text('Modo sin conexión'),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );
}
