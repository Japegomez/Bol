import 'package:flutter/material.dart';

class ServingsResult {
  const ServingsResult({required this.servings, this.isLeftover = false});

  final int servings;
  final bool isLeftover;
}

/// Shown after selecting a recipe: asks for number of servings and whether
/// this is a leftover (skips shopping-list sync when true).
Future<ServingsResult?> showServingsDialog(
  BuildContext context, {
  required int defaultServings,
  bool canConfirm = true,
}) {
  return showDialog<ServingsResult>(
    context: context,
    builder: (context) => _ServingsDialog(
      defaultServings: defaultServings,
      canConfirm: canConfirm,
    ),
  );
}

/// Shown when the user taps "Añadir texto" in the recipe picker.
/// Returns notes text + servings, or null if cancelled.
Future<({String notes, int servings})?> showAddTextDialog(
  BuildContext context, {
  bool canConfirm = true,
}) {
  return showDialog<({String notes, int servings})>(
    context: context,
    builder: (context) => _AddTextDialog(canConfirm: canConfirm),
  );
}

// ─── Servings dialog ──────────────────────────────────────────────────────────

class _ServingsDialog extends StatefulWidget {
  const _ServingsDialog({
    required this.defaultServings,
    this.canConfirm = true,
  });

  final int defaultServings;
  final bool canConfirm;

  @override
  State<_ServingsDialog> createState() => _ServingsDialogState();
}

class _ServingsDialogState extends State<_ServingsDialog> {
  late int _servings;
  bool _isLeftover = false;

  @override
  void initState() {
    super.initState();
    _servings = widget.defaultServings > 0 ? widget.defaultServings : 1;
  }

  void _confirm() {
    Navigator.pop(
      context,
      ServingsResult(servings: _servings, isLeftover: _isLeftover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Raciones'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Número de raciones'),
          ),
          const SizedBox(height: 8),
          _ServingsStepper(
            value: _servings,
            onChanged: (value) => setState(() => _servings = value),
          ),
          const SizedBox(height: 12),
          _LeftoverCheckbox(
            value: _isLeftover,
            onChanged: (v) => setState(() => _isLeftover = v ?? false),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: widget.canConfirm ? _confirm : null,
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}

// ─── Add-text dialog ──────────────────────────────────────────────────────────

class _AddTextDialog extends StatefulWidget {
  const _AddTextDialog({this.canConfirm = true});

  final bool canConfirm;

  @override
  State<_AddTextDialog> createState() => _AddTextDialogState();
}

class _AddTextDialogState extends State<_AddTextDialog> {
  final _notesController = TextEditingController();
  int _servings = 1;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _confirm() {
    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe un nombre para la comida')),
      );
      return;
    }
    Navigator.pop(context, (
      notes: notes,
      servings: _servings,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir texto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: 'Nombre (ej. Pedido a domicilio)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text('Raciones'),
          ),
          const SizedBox(height: 8),
          _ServingsStepper(
            value: _servings,
            onChanged: (value) => setState(() => _servings = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: widget.canConfirm ? _confirm : null,
          child: const Text('Añadir'),
        ),
      ],
    );
  }
}

// ─── Servings stepper ────────────────────────────────────────────────────────

class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;
  static const _min = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: value > _min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
          tooltip: 'Menos raciones',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            '$value',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add),
          tooltip: 'Más raciones',
        ),
      ],
    );
  }
}

// ─── Shared checkbox ─────────────────────────────────────────────────────────

class _LeftoverCheckbox extends StatelessWidget {
  const _LeftoverCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Son sobras',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'No se añadirán ingredientes a la lista de la compra',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
