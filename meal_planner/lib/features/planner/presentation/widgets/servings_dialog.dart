import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';

class ServingsResult {
  const ServingsResult({required this.servings});

  final int servings;
}

/// Shown after selecting a recipe: asks for number of servings.
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

/// Shown when the user taps "Add text" in the recipe picker.
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

  @override
  void initState() {
    super.initState();
    _servings = widget.defaultServings > 0 ? widget.defaultServings : 1;
  }

  void _confirm() {
    Navigator.pop(context, ServingsResult(servings: _servings));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.servingsTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.servingsCountLabel),
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: widget.canConfirm ? _confirm : null,
          child: Text(l10n.confirm),
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
    if (!widget.canConfirm) return;

    final notes = _notesController.text.trim();
    if (notes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.enterMealName)));
      return;
    }
    Navigator.pop(context, (notes: notes, servings: _servings));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.addTextTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.mealNameLabel,
              border: const OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: widget.canConfirm ? (_) => _confirm() : null,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(l10n.servingsTitle),
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
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: widget.canConfirm ? _confirm : null,
          child: Text(l10n.add),
        ),
      ],
    );
  }
}

// ─── Servings stepper ────────────────────────────────────────────────────────

class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;
  static const _min = 1;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filledTonal(
          onPressed: value > _min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove),
          tooltip: l10n.fewerServingsTooltip,
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
          tooltip: l10n.moreServingsTooltip,
        ),
      ],
    );
  }
}
