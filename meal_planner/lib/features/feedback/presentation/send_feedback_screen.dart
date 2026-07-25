import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/feedback/domain/user_feedback.dart';
import 'package:meal_planner/features/feedback/presentation/feedback_provider.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

class SendFeedbackScreen extends ConsumerStatefulWidget {
  const SendFeedbackScreen({super.key});

  @override
  ConsumerState<SendFeedbackScreen> createState() => _SendFeedbackScreenState();
}

class _SendFeedbackScreenState extends ConsumerState<SendFeedbackScreen> {
  FeedbackCategory? _category;
  final _messageController = TextEditingController();
  var _step = 1;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, FeedbackCategory category) {
    return switch (category) {
      FeedbackCategory.issue => l10n.feedbackCategoryIssue,
      FeedbackCategory.feature => l10n.feedbackCategoryFeature,
      FeedbackCategory.other => l10n.feedbackCategoryOther,
    };
  }

  Future<void> _submit() async {
    final category = _category;
    if (category == null) return;

    final l10n = context.l10n;
    try {
      await ref.read(submitFeedbackProvider.notifier).submit(
            category: category,
            message: _messageController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.feedbackSentSuccess)),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      final message = error is ArgumentError
          ? l10n.feedbackMessageTooShort
          : l10n.feedbackSendError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final submitting = ref.watch(submitFeedbackProvider).isLoading;
    final messageLength = _messageController.text.trim().length;
    final canSubmit = messageLength >= 10 && !submitting;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendFeedback),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (_step == 1) ...[
            Text(
              l10n.feedbackWhatAbout,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            for (final category in FeedbackCategory.values) ...[
              Card(
                child: ListTile(
                  title: Text(_categoryLabel(l10n, category)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: submitting
                      ? null
                      : () => setState(() {
                            _category = category;
                            _step = 2;
                          }),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ] else ...[
            Text(
              l10n.feedbackTypeLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _categoryLabel(l10n, _category!),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              l10n.feedbackYourMessage,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              enabled: !submitting,
              minLines: 5,
              maxLines: 10,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: l10n.feedbackMessageHint,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.feedbackMinCharsHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: submitting
                        ? null
                        : () => setState(() {
                              _step = 1;
                              _category = null;
                            }),
                    child: Text(l10n.back),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canSubmit ? _submit : null,
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.send),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
