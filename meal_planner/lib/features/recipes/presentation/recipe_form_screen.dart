import 'dart:typed_data';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/ingredient_row.dart';

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
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    setState(() {
      _localPhotoPreview = bytes;
      _data!
        ..pendingPhoto = file
        ..removePhoto = false;
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
        builder: (context) => AlertDialog(
          title: const Text('Publicar receta'),
          content: const Text(
            'Esta receta será visible para todos los usuarios de MealPlanner. '
            'Podrás despublicarla en cualquier momento.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Publicar'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    } else if (data.isPublic) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hacer receta privada'),
          content: const Text(
            'La receta dejará de ser visible en Explorar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hacer privada'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => data.isPublic = value);
  }

  @override
  Widget build(BuildContext context) {
    final formAsync = ref.watch(recipeFormProvider(widget.recipeId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipeId == null ? 'Nueva receta' : 'Editar receta'),
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
                    onPressed: _save,
                    child: const Text('Guardar'),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: formAsync.when(
        data: (state) {
          if (!_initialized) _initFrom(state.data);
          return _buildForm(context, state.error);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, String? error) {
    final data = _data!;
    const hPad = EdgeInsets.symmetric(horizontal: 16);

    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (error != null) ...[
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        error,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                _PhotoSection(
                  localPreview: _localPhotoPreview,
                  existingPhotoPath:
                      data.removePhoto ? null : data.existingPhotoPath,
                  onPick: _pickPhoto,
                  onRemove: _removePhoto,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Obligatorio' : null,
                  onChanged: (v) => data.title = v,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _servingsController,
                        decoration: const InputDecoration(
                          labelText: 'Raciones',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          return (n == null || n < 1) ? 'Mínimo 1' : null;
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
                        decoration: const InputDecoration(
                          labelText: 'Prep (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => data.prepTime = int.tryParse(v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cookController,
                        decoration: const InputDecoration(
                          labelText: 'Cocción (min)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) => data.cookTime = int.tryParse(v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Etiquetas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...suggestedRecipeTags.map(
                      (tag) => FilterChip(
                        label: Text(tag),
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
                            label: Text(tag),
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
                        decoration: const InputDecoration(
                          labelText: 'Etiqueta personalizada',
                          border: OutlineInputBorder(),
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
                'Ingredientes',
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
                'Pasos',
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
                  decoration: const InputDecoration(
                    labelText: 'Consejos',
                    hintText: 'Trucos, variaciones o notas útiles',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  onChanged: (v) => data.tips = v,
                ),
                const SizedBox(height: 24),
                Text(
                  'Nutrición (por ración)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _NutritionFields(data: data.nutrition),
                const SizedBox(height: 24),
                if (!data.canPublish)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.bookmark_added_outlined),
                      title: Text('Receta guardada de otro usuario'),
                      subtitle: Text(
                        'Las recetas forkeadas no se pueden publicar en Explorar.',
                      ),
                    ),
                  )
                else
                  Card(
                    child: SwitchListTile(
                      title: const Text('Publicar receta'),
                      subtitle: const Text(
                        'Visible para todos los usuarios en Explorar',
                      ),
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
              label: const Text('Añadir ingrediente'),
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
              label: const Text('Añadir paso'),
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
                        labelText: 'Paso ${widget.index + 1}',
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
                title: const Text('Opcional'),
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
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? localPreview;
  final String? existingPhotoPath;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final existingUrlAsync =
        ref.watch(recipePhotoUrlProvider(existingPhotoPath));

    Widget? preview;
    if (localPreview != null) {
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
              onPressed: onPick,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Elegir foto'),
            ),
            if (preview != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRemove,
                child: const Text('Quitar'),
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        _field('Calorías (kcal)', _calories, (v) => widget.data.calories = v),
        _field('Proteínas (g)', _protein, (v) => widget.data.protein = v),
        _field('Carbohidratos (g)', _carbohydrates,
            (v) => widget.data.carbohydrates = v),
        _field('Grasas (g)', _fat, (v) => widget.data.fat = v),
        _field('Fibra (g)', _fiber, (v) => widget.data.fiber = v),
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
