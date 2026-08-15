import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    required this.controller,
    super.key,
    this.labelText,
    this.validator,
    this.autofillHints,
    this.enabled = true,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String? labelText;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late final FocusNode _focusNode;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: widget.labelText);
    _focusNode.addListener(_restoreSelectionIfInvalid);
    widget.controller.addListener(_restoreSelectionIfInvalid);
  }

  @override
  void didUpdateWidget(PasswordTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_restoreSelectionIfInvalid);
      widget.controller.addListener(_restoreSelectionIfInvalid);
    }
    // Showing/hiding FormField error text rebuilds the decorator and can leave
    // an invalid selection (esp. on web), which freezes further typing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _restoreSelectionIfInvalid();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_restoreSelectionIfInvalid);
    _focusNode.removeListener(_restoreSelectionIfInvalid);
    _focusNode.dispose();
    super.dispose();
  }

  void _restoreSelectionIfInvalid() {
    if (!_focusNode.hasFocus) return;
    final controller = widget.controller;
    final text = controller.text;
    final selection = controller.selection;
    if (selection.isValid &&
        selection.start >= 0 &&
        selection.end <= text.length) {
      return;
    }
    controller.selection = TextSelection.collapsed(offset: text.length);
  }

  /// Chrome's password generator (`new-password`) desyncs Flutter's web
  /// overlay input after blur, which freezes typing and deletion.
  Iterable<String>? get _effectiveAutofillHints {
    final hints = widget.autofillHints;
    if (hints == null || !kIsWeb) return hints;
    return List<String>.unmodifiable(
      hints.where((hint) => hint != AutofillHints.newPassword),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      enableInteractiveSelection: true,
      autofillHints: _effectiveAutofillHints,
      enabled: widget.enabled,
      textInputAction: widget.textInputAction,
      autovalidateMode: AutovalidateMode.onUnfocus,
      onTap: _restoreSelectionIfInvalid,
      onChanged: (_) => _restoreSelectionIfInvalid(),
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        border: const OutlineInputBorder(),
        errorMaxLines: 3,
        suffixIcon: ExcludeFocus(
          child: IconButton(
            onPressed: widget.enabled
                ? () => setState(() => _obscure = !_obscure)
                : null,
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            tooltip: _obscure ? l10n.showPassword : l10n.hidePassword,
          ),
        ),
      ),
    );
  }
}
