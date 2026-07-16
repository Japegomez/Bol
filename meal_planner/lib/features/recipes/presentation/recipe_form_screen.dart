import 'dart:typed_data';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/config/app_branding.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/core/moderation/image_moderation_ui.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/ingredient_row.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/recipe_assistant_prompt_sheet.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

String _resolveFormError(String error, AppLocalizations l10n) {
  return switch (error) {
    householdLoadErrorKey => l10n.householdLoadError,
    _ => error,
  };
}

/// Elevates the dragged row while reordering (SliverReorderableList has no
/// default proxy decoration unlike ReorderableListView).
Widget _reorderProxyDecorator(
  Widget child,
  int index,
  Animation<double> animation,
) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, child) {
      final t = Curves.easeInOut.transform(animation.value);
      final elevation = lerpDouble(0, 6, t)!;
      return Material(
        elevation: elevation,
        color: Colors.transparent,
        shadowColor: Theme.of(context).shadowColor,
        borderRadius: BorderRadius.circular(12),
        child: child,
      );
    },
    child: child,
  );
}

class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({this.recipeId, super.key});

  final String? recipeId;

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();

  RecipeFormData? _data;
  bool _initialized = false;

  TextEditingController? _titleController;
  TextEditingController? _servingsController;
  TextEditingController? _prepController;
  TextEditingController? _cookController;
  TextEditingController? _tipsController;

  Uint8List? _localPhotoPreview;
  bool _isModeratingPhoto = false;
  String? _photoModerationError;
  bool _isGeneratingNutrition = false;

  @override
  void dispose() {
    _tagController.dispose();
    _titleController?.dispose();
    _servingsController?.dispose();
    _prepController?.dispose();
    _cookController?.dispose();
    _tipsController?.dispose();
    super.dispose();
  }

  void _initFrom(RecipeFormData data) {
    _data = data;
    _titleController = TextEditingController(text: data.title);
    _servingsController = TextEditingController(text: data.servings.toString());
    _prepController =
        TextEditingController(text: data.prepTime?.toString() ?? '');
    _cookController =
        TextEditingController(text: data.cookTime?.toString() ?? '');
    _tipsController = TextEditingController(text: data.tips);
    _initialized = true;
  }

  Future<void> _pickPhoto() async {
    if (ref.read(isOfflineProvider)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.photoRequiresConnection),
        ),
      );
      return;
    }
    if (_isModeratingPhoto) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _isModeratingPhoto = true;
      _photoModerationError = null;
    });

    if (!mounted) return;

    final allowed = await moderatePickedImage(
      context: context,
      ref: ref,
      bytes: bytes,
      onServiceError: (message) => _photoModerationError = message,
    );

    if (!mounted) return;
    setState(() {
      _isModeratingPhoto = false;
      if (allowed) {
        _localPhotoPreview = bytes;
        _data!
          ..pendingPhoto = file
          ..removePhoto = false;
      }
    });
  }

  void _removePhoto() {
    setState(() {
      _localPhotoPreview = null;
      _data!
        ..pendingPhoto = null
        ..removePhoto = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final formState = ref.read(recipeFormProvider(widget.recipeId)).valueOrNull;
    if (formState?.isSaving ?? false) return;
    final notifier = ref.read(recipeFormProvider(widget.recipeId).notifier);
    notifier.setData(_data!);
    final id = await notifier.save();
    if (!mounted || id == null) return;
    context.go('/home/recipes/$id');
  }

  Future<void> _togglePublic(bool value) async {
    final data = _data!;
    if (!data.canPublish) return;
    if (value) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogL10n = dialogContext.l10n;
          return AlertDialog(
            title: Text(dialogL10n.publishRecipeTitle),
            content: Text(
              dialogL10n.publishRecipeMessage(AppBranding.displayName),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(dialogL10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(dialogL10n.publish),
              ),
            ],
          );
        },
      );
      if (confirmed != true || !mounted) return;
    } else if (data.isPublic) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogL10n = dialogContext.l10n;
          return AlertDialog(
            title: Text(dialogL10n.makeRecipePrivateTitle),
            content: Text(dialogL10n.makeRecipePrivateMessageForm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(dialogL10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(dialogL10n.makePrivate),
              ),
            ],
          );
        },
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => data.isPublic = value);
  }

  Future<void> _generateNutritionWithAssistant() async {
    if (_data == null || _isGeneratingNutrition) return;

    setState(() => _isGeneratingNutrition = true);
    try {
      await generateNutritionWithAssistant(
        ref: ref,
        context: context,
        title: _data!.title,
        servings: _data!.servings,
        ingredients: _data!.ingredients,
        onSuccess: (nutrition) {
          if (!mounted) return;
          setState(() {
            _data!.nutrition
              ..calories = nutrition.calories
              ..protein = nutrition.protein
              ..carbohydrates = nutrition.carbohydrates
              ..fat = nutrition.fat
              ..fiber = nutrition.fiber;
          });
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingNutrition = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formAsync = ref.watch(recipeFormProvider(widget.recipeId));
    final canEdit = ref.watch(canEditOfflineProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipeId == null ? l10n.newRecipeTitle : l10n.editRecipeTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          formAsync.maybeWhen(
            data: (state) => state.isSaving
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: canEdit ? _save : null,
                    child: Text(l10n.save),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: formAsync.when(
        data: (state) {
          if (!_initialized) _initFrom(state.data);
          return _buildForm(context, state.error, canEdit: canEdit);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text(l10n.errorWithMessage('$error'))),
      ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    String? error, {
    required bool canEdit,
  }) {
    final l10n = context.l10n;
    final data = _data!;
    const hPad = EdgeInsets.symmetric(horizontal: 16);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!canEdit)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(l10n.householdEditRequiresConnection),
                ),
              ),
            ),
          if (error != null || _photoModerationError != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _resolveFormError(
                      error ?? _photoModerationError!,
                      l10n,
                    ),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: AbsorbPointer(
              absorbing: !canEdit,
              child: CustomScrollView(
                slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PhotoSection(
                  localPreview: _localPhotoPreview,
                  existingPhotoPath:
                      data.removePhoto ? null : data.existingPhotoPath,
                  isModerating: _isModeratingPhoto,
                  onPick: _pickPhoto,
                  onRemove: _removePhoto,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.nameLabel,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.requiredField : null,
                  onChanged: (v) => data.title = v,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        decoration: InputDecoration(
                          labelText: l10n.servingsLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          return (n == null || n < 1) ? l10n.minOneServing : null;
                        },
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) data.servings = n;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _prepController,
                        decoration: InputDecoration(
                          labelText: l10n.prepMinLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => data.prepTime = int.tryParse(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cookController,
                        decoration: InputDecoration(
                          labelText: l10n.cookMinLabel,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => data.cookTime = int.tryParse(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.tagsSection,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...suggestedRecipeTags.map(
                      (tag) => FilterChip(
                        label: Text(localizedTagLabel(l10n, tag)),
                        selected: data.tags.contains(tag),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            data.tags.add(tag);
                          } else {
                            data.tags.remove(tag);
                          }
                        }),
                      ),
                    ),
                    ...data.tags
                        .where((t) => !suggestedRecipeTags.contains(t))
                        .map(
                          (tag) => InputChip(
                            label: Text(localizedTagLabel(l10n, tag)),
                            onDeleted: () =>
                                setState(() => data.tags.remove(tag)),
                          ),
                        ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _tagController,
                        decoration: InputDecoration(
                          labelText: l10n.customTagLabel,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        final tag = _tagController.text.trim();
                        if (tag.isEmpty || data.tags.contains(tag)) return;
                        _tagController.clear();
                        setState(() => data.tags.add(tag));
                      },
                    ),
                  ],
                ),
              ]),
            ),
          ),

          // ── Ingredientes (lazy sliver + auto-scroll on drag) ────────────────
          SliverPadding(
            padding: hPad.copyWith(top: 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.ingredientsSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: hPad.copyWith(top: 8),
            sliver: _IngredientsSliverSection(ingredients: data.ingredients),
          ),

          // ── Pasos (lazy sliver + auto-scroll on drag) ─────────────────────
          SliverPadding(
            padding: hPad.copyWith(top: 24),
            sliver: SliverToBoxAdapter(
              child: Text(
                l10n.stepsSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          SliverPadding(
            padding: hPad.copyWith(top: 8),
            sliver: _StepsSliverSection(steps: data.steps),
          ),

          // ── Consejos, nutrición, publicar ─────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                TextFormField(
                  controller: _tipsController,
                  decoration: InputDecoration(
                    labelText: l10n.tipsLabel,
                    hintText: l10n.tipsHint,
                    border: const OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  onChanged: (v) => data.tips = v,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.nutritionPerServing,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _isGeneratingNutrition
                        ? null
                        : _generateNutritionWithAssistant,
                    icon: _isGeneratingNutrition
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome_outlined),
                    label: Text(l10n.completeNutritionWithAssistant),
                  ),
                ),
                const SizedBox(height: 8),
                _NutritionFields(
                  data: data.nutrition,
                ),
                const SizedBox(height: 24),
                if (!data.canPublish)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.bookmark_added_outlined),
                      title: Text(l10n.forkedRecipeTitle),
                      subtitle: Text(l10n.forkedRecipeCannotPublish),
                    ),
                  )
                else
                  Card(
                    child: SwitchListTile(
                      title: Text(l10n.publishRecipeTitle),
                      subtitle: Text(l10n.visibleInExploreShort),
                      secondary: const Icon(Icons.public),
                      value: data.isPublic,
                      onChanged: _togglePublic,
                    ),
                  ),
              ]),
            ),
          ),
        ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sliver de ingredientes (lazy + auto-scroll)
// ──────────────────────────────────────────────────────────────────────────────

class _IngredientsSliverSection extends StatefulWidget {
  const _IngredientsSliverSection({required this.ingredients});

  final List<IngredientFormItem> ingredients;

  @override
  State<_IngredientsSliverSection> createState() =>
      _IngredientsSliverSectionState();
}

class _IngredientsSliverSectionState extends State<_IngredientsSliverSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = widget.ingredients;
    return SliverMainAxisGroup(
      slivers: [
        SliverReorderableList(
          itemCount: items.length,
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          },
          proxyDecorator: _reorderProxyDecorator,
          itemBuilder: (context, index) {
            final ingredient = items[index];
            return ReorderableDelayedDragStartListener(
              key: ValueKey(ingredient.key),
              index: index,
              child: IngredientRow(
                index: index,
                ingredient: ingredient,
                canRemove: items.length > 1,
                onRemove: () => setState(() => items.removeAt(index)),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () =>
                  setState(() => items.add(IngredientFormItem())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addIngredient),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sliver de pasos (lazy + auto-scroll)
// ──────────────────────────────────────────────────────────────────────────────

class _StepsSliverSection extends StatefulWidget {
  const _StepsSliverSection({required this.steps});

  final List<StepFormItem> steps;

  @override
  State<_StepsSliverSection> createState() => _StepsSliverSectionState();
}

class _StepsSliverSectionState extends State<_StepsSliverSection> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = widget.steps;
    return SliverMainAxisGroup(
      slivers: [
        SliverReorderableList(
          itemCount: items.length,
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              final item = items.removeAt(oldIndex);
              items.insert(newIndex, item);
            });
          },
          proxyDecorator: _reorderProxyDecorator,
          itemBuilder: (context, index) {
            final step = items[index];
            return ReorderableDelayedDragStartListener(
              key: ValueKey(step.key),
              index: index,
              child: _StepRow(
                index: index,
                step: step,
                canRemove: items.length > 1,
                onRemove: () => setState(() => items.removeAt(index)),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => items.add(StepFormItem())),
              icon: const Icon(Icons.add),
              label: Text(l10n.addStep),
            ),
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Fila de paso individual
// ──────────────────────────────────────────────────────────────────────────────

class _StepRow extends StatefulWidget {
  const _StepRow({
    required this.index,
    required this.step,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final StepFormItem step;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  State<_StepRow> createState() => _StepRowState();
}

class _StepRowState extends State<_StepRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.step.description);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RepaintBoundary(
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReorderableDragStartListener(
                    index: widget.index,
                    child: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: l10n.stepLabel(widget.index + 1),
                        isDense: true,
                      ),
                      maxLines: 3,
                      onChanged: (v) => widget.step.description = v,
                    ),
                  ),
                  if (widget.canRemove)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: widget.onRemove,
                    ),
                ],
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.optional),
                value: widget.step.isOptional,
                onChanged: (v) {
                  if (v != null) setState(() => widget.step.isOptional = v);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Sección de foto
// ──────────────────────────────────────────────────────────────────────────────

class _PhotoSection extends ConsumerWidget {
  const _PhotoSection({
    required this.localPreview,
    required this.existingPhotoPath,
    required this.isModerating,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? localPreview;
  final String? existingPhotoPath;
  final bool isModerating;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final existingUrlAsync =
        ref.watch(recipePhotoUrlProvider(existingPhotoPath));

    Widget? preview;
    if (isModerating) {
      preview = SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(l10n.checkingImage),
            ],
          ),
        ),
      );
    } else if (localPreview != null) {
      preview = Image.memory(localPreview!, height: 180, fit: BoxFit.cover);
    } else if (existingPhotoPath != null) {
      preview = existingUrlAsync.when(
        data: (url) => url == null
            ? null
            : Image.network(url, height: 180, fit: BoxFit.cover),
        loading: () => const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (preview != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: preview,
          )
        else
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.add_a_photo, size: 40)),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: isModerating ? null : onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.choosePhoto),
            ),
            if (preview != null && !isModerating) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRemove,
                child: Text(l10n.remove),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Campos de nutrición
// ──────────────────────────────────────────────────────────────────────────────

class _NutritionFields extends StatefulWidget {
  const _NutritionFields({required this.data});

  final NutritionFormData data;

  @override
  State<_NutritionFields> createState() => _NutritionFieldsState();
}

class _NutritionFieldsState extends State<_NutritionFields> {
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbohydrates;
  late final TextEditingController _fat;
  late final TextEditingController _fiber;

  @override
  void initState() {
    super.initState();
    _calories =
        TextEditingController(text: widget.data.calories?.toString() ?? '');
    _protein =
        TextEditingController(text: widget.data.protein?.toString() ?? '');
    _carbohydrates =
        TextEditingController(text: widget.data.carbohydrates?.toString() ?? '');
    _fat = TextEditingController(text: widget.data.fat?.toString() ?? '');
    _fiber = TextEditingController(text: widget.data.fiber?.toString() ?? '');
  }

  @override
  void dispose() {
    _calories.dispose();
    _protein.dispose();
    _carbohydrates.dispose();
    _fat.dispose();
    _fiber.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _NutritionFields oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllerFromData(_calories, widget.data.calories);
    _syncControllerFromData(_protein, widget.data.protein);
    _syncControllerFromData(_carbohydrates, widget.data.carbohydrates);
    _syncControllerFromData(_fat, widget.data.fat);
    _syncControllerFromData(_fiber, widget.data.fiber);
  }

  void _syncControllerFromData(TextEditingController controller, num? value) {
    final newText = value?.toString() ?? '';
    if (controller.text == newText) return;

    final currentParsed = num.tryParse(controller.text.replaceAll(',', '.'));
    if (currentParsed != null && value != null && currentParsed == value) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _field(l10n.caloriesKcal, _calories, (v) => widget.data.calories = v),
        _field(l10n.proteinG, _protein, (v) => widget.data.protein = v),
        _field(l10n.carbohydratesG, _carbohydrates,
            (v) => widget.data.carbohydrates = v),
        _field(l10n.fatG, _fat, (v) => widget.data.fat = v),
        _field(l10n.fiberG, _fiber, (v) => widget.data.fiber = v),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    ValueChanged<num?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (t) => onChanged(num.tryParse(t.replaceAll(',', '.'))),
      ),
    );
  }
}
