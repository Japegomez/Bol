import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/features/recipes/data/recipe_assistant_repository.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/l10n/app_localizations.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

String resolveRecipeAssistantError(String error, AppLocalizations l10n) {
  return switch (error) {
    recipeAssistantNotRecipeRequestKey => l10n.recipeAssistantNotRecipeRequest,
    recipeAssistantRateLimitedKey => l10n.recipeAssistantRateLimited,
    recipeAssistantDailyLimitKey => l10n.recipeAssistantDailyLimitReached,
    recipeAssistantTooFastKey => l10n.recipeAssistantTooFast,
    recipeAssistantServiceAtCapacityKey => l10n.recipeAssistantServiceAtCapacity,
    recipeAssistantOfflineKey => l10n.recipeAssistantOffline,
    recipeAssistantNotConfiguredKey => l10n.recipeAssistantNotConfigured,
    recipeAssistantTimeoutKey => l10n.recipeAssistantTimeout,
    recipeAssistantPromptTooLongKey => l10n.recipeAssistantPromptTooLong,
    recipeAssistantMissingInputKey => l10n.recipeAssistantMissingInput,
    recipeAssistantImageTooLargeKey => l10n.recipeAssistantImageTooLarge,
    recipeAssistantInvalidImageKey => l10n.recipeAssistantInvalidImage,
    _ => l10n.recipeAssistantFailed,
  };
}

/// Runs [task] while showing a full-screen modal that blocks all app interaction.
Future<T> runWithRecipeAssistantBlockingOverlay<T>({
  required BuildContext context,
  required String message,
  required Future<T> Function() task,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    useRootNavigator: true,
    pageBuilder: (dialogContext, _, _) => PopScope(
      canPop: false,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(dialogContext).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  try {
    return await task();
  } finally {
    if (navigator.mounted) {
      navigator.pop();
    }
  }
}

/// Returns the user's prompt input, or `null` if the sheet was dismissed.
Future<RecipeAssistantPromptInput?> showRecipeAssistantPromptSheet(
  BuildContext context,
) {
  return showModalBottomSheet<RecipeAssistantPromptInput>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => const _RecipeAssistantPromptSheet(),
  );
}

class _RecipeAssistantPromptSheet extends ConsumerStatefulWidget {
  const _RecipeAssistantPromptSheet();

  @override
  ConsumerState<_RecipeAssistantPromptSheet> createState() =>
      _RecipeAssistantPromptSheetState();
}

class _RecipeAssistantPromptSheetState
    extends ConsumerState<_RecipeAssistantPromptSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  final _speech = SpeechToText();

  final List<RecipeAssistantImageInput> _images = [];
  String? _error;
  bool _pickingImage = false;

  bool _speechReady = false;
  bool _speechUnavailable = false;
  bool _listening = false;
  bool _speechInitInFlight = false;
  bool _dictationStarting = false;
  String _dictationPrefix = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    unawaited(_speech.stop());
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final hasText = _controller.text.trim().isNotEmpty;
    return hasText || _images.isNotEmpty;
  }

  bool get _canAddImage => _images.length < maxRecipeAssistantImages;

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) return true;
    if (_speechUnavailable) return false;
    if (_speechInitInFlight) return false;

    _speechInitInFlight = true;
    try {
      final available = await _speech.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );
      if (!mounted) return false;
      setState(() {
        _speechReady = available;
        _speechUnavailable = !available;
        if (!available) {
          _error = context.l10n.recipeAssistantSpeechUnavailable;
        }
      });
      return available;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _speechReady = false;
        _speechUnavailable = true;
        _error = context.l10n.recipeAssistantSpeechUnavailable;
      });
      return false;
    } finally {
      _speechInitInFlight = false;
    }
  }

  void _onSpeechStatus(String status) {
    if (!mounted) return;
    final listening = status == SpeechToText.listeningStatus;
    if (_listening != listening) {
      setState(() => _listening = listening);
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted) return;
    setState(() {
      _listening = false;
      if (error.permanent) {
        _speechUnavailable = true;
        _error = context.l10n.recipeAssistantSpeechUnavailable;
      } else {
        _error = context.l10n.recipeAssistantSpeechFailed;
      }
    });
  }

  Future<String?> _speechLocaleId() async {
    final appLocale = Localizations.localeOf(context);
    final locales = await _speech.locales();
    if (locales.isEmpty) return null;

    final language = appLocale.languageCode.toLowerCase();
    final country = appLocale.countryCode?.toLowerCase();

    if (country != null && country.isNotEmpty) {
      final exact = '$language-$country';
      for (final locale in locales) {
        if (locale.localeId.toLowerCase() == exact) {
          return locale.localeId;
        }
      }
    }

    for (final locale in locales) {
      final id = locale.localeId.toLowerCase();
      if (id == language || id.startsWith('$language-') || id.startsWith('${language}_')) {
        return locale.localeId;
      }
    }

    return (await _speech.systemLocale())?.localeId;
  }

  void _applyDictationText(String spoken, {required bool isFinal}) {
    final spokenTrimmed = spoken.trim();
    String combined;
    if (_dictationPrefix.isEmpty) {
      combined = spokenTrimmed;
    } else if (spokenTrimmed.isEmpty) {
      combined = _dictationPrefix;
    } else {
      combined = '$_dictationPrefix $spokenTrimmed';
    }

    if (combined.length > maxRecipeAssistantPromptLength) {
      combined = combined.substring(0, maxRecipeAssistantPromptLength);
    }

    _controller.value = TextEditingValue(
      text: combined,
      selection: TextSelection.collapsed(offset: combined.length),
    );

    if (isFinal) {
      _dictationPrefix = combined.trimRight();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    _applyDictationText(result.recognizedWords, isFinal: result.finalResult);
  }

  Future<void> _toggleDictation() async {
    if (_pickingImage || _dictationStarting) return;

    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    setState(() {
      _dictationStarting = true;
      _error = null;
    });
    try {
      final ready = await _ensureSpeechReady();
      if (!ready || !mounted) return;

      _dictationPrefix = _controller.text.trimRight();
      final localeId = await _speechLocaleId();
      if (!mounted) return;

      try {
        await _speech.listen(
          onResult: _onSpeechResult,
          listenOptions: SpeechListenOptions(
            partialResults: true,
            cancelOnError: true,
            listenMode: ListenMode.confirmation,
            localeId: localeId,
          ),
        );
        if (mounted) setState(() => _listening = true);
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _listening = false;
          _error = context.l10n.recipeAssistantSpeechFailed;
        });
      }
    } finally {
      if (mounted) setState(() => _dictationStarting = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_pickingImage || !_canAddImage) return;
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
    }

    setState(() {
      _pickingImage = true;
      _error = null;
    });

    try {
      final remaining = maxRecipeAssistantImages - _images.length;
      final files = <XFile>[];
      if (source == ImageSource.gallery && remaining > 1) {
        files.addAll(
          await _picker.pickMultiImage(
            maxWidth: 1280,
            imageQuality: 70,
            limit: remaining,
          ),
        );
      } else {
        final file = await _picker.pickImage(
          source: source,
          maxWidth: 1280,
          imageQuality: 70,
        );
        if (file != null) files.add(file);
      }
      if (files.isEmpty || !mounted) return;

      await _addImageFiles(files);
    } on Object {
      if (!mounted) return;
      setState(() => _error = context.l10n.recipeAssistantInvalidImage);
    } finally {
      if (mounted) setState(() => _pickingImage = false);
    }
  }

  Future<void> _addImageFiles(List<XFile> files) async {
    final remaining = maxRecipeAssistantImages - _images.length;
    final toAdd = files.take(remaining);
    String? error;
    final added = <RecipeAssistantImageInput>[];

    for (final file in toAdd) {
      final bytes = await file.readAsBytes();
      if (!mounted) return;

      if (bytes.isEmpty) {
        error = context.l10n.recipeAssistantInvalidImage;
        continue;
      }
      if (bytes.length > maxRecipeAssistantImageBytes) {
        error = context.l10n.recipeAssistantImageTooLarge;
        continue;
      }

      added.add(
        RecipeAssistantImageInput(
          bytes: bytes,
          mimeType: _mimeTypeForBytes(bytes),
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _images.addAll(added);
      _error = error;
    });
  }

  void _removeImageAt(int index) {
    setState(() {
      _images.removeAt(index);
      _error = null;
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (_listening) {
      await _speech.stop();
    }
    if (!mounted) return;
    Navigator.pop(
      context,
      RecipeAssistantPromptInput(
        prompt: _controller.text.trim(),
        images: List<RecipeAssistantImageInput>.from(_images),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isOffline = ref.watch(isOfflineProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canGenerate =
        !isOffline && _canSubmit && !_pickingImage && !_listening;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.recipeAssistantTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.recipeAssistantDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !isOffline && !_listening,
            maxLines: 5,
            minLines: 3,
            maxLength: maxRecipeAssistantPromptLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            inputFormatters: [
              LengthLimitingTextInputFormatter(maxRecipeAssistantPromptLength),
            ],
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: _listening
                  ? l10n.recipeAssistantListening
                  : _images.isNotEmpty
                      ? l10n.recipeAssistantImagePromptHint
                      : l10n.recipeAssistantPromptHint,
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onSubmitted: (_) {
              if (!_listening) unawaited(_submit());
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_pickingImage) ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
              ],
              IconButton.filledTonal(
                onPressed: isOffline ||
                        _pickingImage ||
                        _listening ||
                        !_canAddImage
                    ? null
                    : () => _pickImage(ImageSource.camera),
                tooltip: l10n.camera,
                icon: const Icon(Icons.photo_camera_outlined),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                onPressed: isOffline ||
                        _pickingImage ||
                        _listening ||
                        !_canAddImage
                    ? null
                    : () => _pickImage(ImageSource.gallery),
                tooltip: l10n.choosePhoto,
                icon: const Icon(Icons.photo_library_outlined),
              ),
              const SizedBox(width: 4),
              IconButton.filledTonal(
                onPressed: isOffline ||
                        _pickingImage ||
                        _speechUnavailable ||
                        _dictationStarting
                    ? null
                    : () => unawaited(_toggleDictation()),
                tooltip: _listening
                    ? l10n.recipeAssistantStopDictation
                    : l10n.recipeAssistantDictate,
                style: _listening
                    ? IconButton.styleFrom(
                        backgroundColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.onErrorContainer,
                      )
                    : null,
                icon: Icon(_listening ? Icons.mic : Icons.mic_none),
              ),
            ],
          ),
          if (_images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return _AttachedPhotoThumb(
                    bytes: _images[index].bytes,
                    removeTooltip: l10n.remove,
                    onRemove: isOffline || _listening
                        ? null
                        : () => _removeImageAt(index),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.recipeAssistantSameRecipePhotosHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          if (isOffline) ...[
            const SizedBox(height: 8),
            Text(
              l10n.recipeAssistantOffline,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: canGenerate ? () => unawaited(_submit()) : null,
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.recipeAssistantGenerate),
          ),
        ],
      ),
    );
  }
}

class _AttachedPhotoThumb extends StatelessWidget {
  const _AttachedPhotoThumb({
    required this.bytes,
    required this.removeTooltip,
    required this.onRemove,
  });

  final Uint8List bytes;
  final String removeTooltip;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                bytes,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: removeTooltip,
              onPressed: onRemove,
              visualDensity: VisualDensity.compact,
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.92),
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size(28, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              icon: const Icon(Icons.close, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

String _mimeTypeForBytes(Uint8List bytes) {
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0D &&
      bytes[5] == 0x0A &&
      bytes[6] == 0x1A &&
      bytes[7] == 0x0A) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[7] == 0x57 &&
      bytes[8] == 0x45 &&
      bytes[9] == 0x42 &&
      bytes[10] == 0x50) {
    return 'image/webp';
  }
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
    return 'image/jpeg';
  }
  // image_picker recompresses to JPEG by default; safe fallback.
  return 'image/jpeg';
}

Future<void> generateNutritionWithAssistant({
  required WidgetRef ref,
  required BuildContext context,
  required String title,
  required int servings,
  required List<IngredientFormItem> ingredients,
  required FutureOr<void> Function(NutritionFormData nutrition) onSuccess,
  NutritionFormData? existingNutrition,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);

  NutritionFormData nutrition;
  try {
    nutrition = await runWithRecipeAssistantBlockingOverlay(
      context: context,
      message: l10n.recipeAssistantBlockingNutrition,
      task: () => ref.read(recipeAssistantRepositoryProvider).generateNutrition(
            title: title,
            servings: servings,
            ingredients: ingredients,
            existingNutrition: existingNutrition,
          ),
    );
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          resolveRecipeAssistantError(
            error.toString().replaceFirst('Exception: ', ''),
            l10n,
          ),
        ),
      ),
    );
    return;
  }

  try {
    await onSuccess(nutrition);
  } catch (error) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          resolveRecipeAssistantError(
            error.toString().replaceFirst('Exception: ', ''),
            l10n,
          ),
        ),
      ),
    );
  }
}
