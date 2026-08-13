import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/widgets/app_button.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

class JoinHouseholdScreen extends ConsumerStatefulWidget {
  const JoinHouseholdScreen({super.key, this.initialCode});

  /// Pre-filled invite code from a household deep link (`?code=` / `/h/:code`).
  final String? initialCode;

  @override
  ConsumerState<JoinHouseholdScreen> createState() =>
      _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends ConsumerState<JoinHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initial = (widget.initialCode ?? '').trim().toUpperCase();
    _codeController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(currentHouseholdProvider.notifier)
          .join(_codeController.text.trim().toUpperCase());
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = _mapJoinError(context.l10n, e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapJoinError(AppLocalizations l10n, String message) {
    if (message.contains('Invalid invite code')) {
      return l10n.invalidInviteCode;
    }
    if (message.contains('Already a member')) {
      return l10n.alreadyMember;
    }
    if (message.contains('Too many attempts')) {
      return l10n.tooManyAttempts;
    }
    if (message.contains('Please wait a moment')) {
      return l10n.pleaseWaitMoment;
    }
    // Don't surface raw backend exception strings to the user.
    return l10n.genericErrorMessage;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.joinHouseholdTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.joinCodeInstructions,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: l10n.inviteCode,
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  hintText: 'ABCD1234',
                ),
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(8),
                  UpperCaseTextFormatter(),
                ],
                enabled: !_isLoading,
                validator: (value) {
                  final length = value?.trim().length ?? 0;
                  if (length != 6 && length != 8) {
                    return l10n.codeMustBeSixChars;
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: l10n.join,
                isLoading: _isLoading,
                onPressed: _join,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
