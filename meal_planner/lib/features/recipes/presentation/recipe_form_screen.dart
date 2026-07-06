import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/features/recipes/domain/recipe_constants.dart';
import 'package:meal_planner/features/recipes/domain/recipe_form_data.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_provider.dart';
import 'package:meal_planner/features/recipes/presentation/widgets/ingredient_row.dart';

class RecipeFormScreen extends ConsumerStatefulWidget {
  const RecipeFormScreen({this.recipeId, super.key});

  final String? recipeId;

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagController = TextEditingController();
  Uint8List? _localPhotoPreview;

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(RecipeFormData data) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    setState(() => _localPhotoPreview = bytes);

    final updated = RecipeFormData(
      title: data.title,
      servings: data.servings,
      prepTime: data.prepTime,
      cookTime: data.cookTime,
      tags: data.tags,
      ingredients: data.ingredients,
      steps: data.steps,
      nutrition: data.nutrition,
      existingPhotoPath: data.existingPhotoPath,
      removePhoto: false,
      pendingPhoto: file,
      isPublic: data.isPublic,
      forkedFromId: data.forkedFromId,
      tips: data.tips,
    );
    ref.read(recipeFormProvider(widget.recipeId).notifier).updateData(updated);
  }

  void _removePhoto(RecipeFormData data) {
    setState(() => _localPhotoPreview = null);
    final updated = RecipeFormData(
      title: data.title,
      servings: data.servings,
      prepTime: data.prepTime,
      cookTime: data.cookTime,
      tags: data.tags,
      ingredients: data.ingredients,
      steps: data.steps,
      nutrition: data.nutrition,
      existingPhotoPath: data.existingPhotoPath,
      removePhoto: true,
      isPublic: data.isPublic,
      forkedFromId: data.forkedFromId,
      tips: data.tips,
    );
    ref.read(recipeFormProvider(widget.recipeId).notifier).updateData(updated);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id =
        await ref.read(recipeFormProvider(widget.recipeId).notifier).save();
    if (!mounted || id == null) return;
    context.go('/home/recipes/$id');
  }

  void _updateForm(RecipeFormData data) {
    ref.read(recipeFormProvider(widget.recipeId).notifier).updateData(data);
    setState(() {});
  }

  RecipeFormData _copyData(RecipeFormData data) {
    return RecipeFormData(
      title: data.title,
      servings: data.servings,
      prepTime: data.prepTime,
      cookTime: data.cookTime,
      tags: List<String>.from(data.tags),
      ingredients: List<IngredientFormItem>.from(data.ingredients),
      steps: List<StepFormItem>.from(data.steps),
      nutrition: NutritionFormData(
        calories: data.nutrition.calories,
        protein: data.nutrition.protein,
        carbohydrates: data.nutrition.carbohydrates,
        fat: data.nutrition.fat,
        fiber: data.nutrition.fiber,
      ),
      existingPhotoPath: data.existingPhotoPath,
      removePhoto: data.removePhoto,
      pendingPhoto: data.pendingPhoto,
      isPublic: data.isPublic,
      forkedFromId: data.forkedFromId,
      tips: data.tips,
    );
  }

  Future<void> _togglePublic(RecipeFormData data, bool value) async {
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

    final copy = _copyData(data);
    copy.isPublic = value;
    _updateForm(copy);
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
        data: (state) => _buildForm(context, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildForm(BuildContext context, RecipeFormState state) {
    final data = state.data;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.error != null) ...[
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  state.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          _PhotoSection(
            localPreview: _localPhotoPreview,
            existingPhotoPath: data.removePhoto ? null : data.existingPhotoPath,
            onPick: () => _pickPhoto(data),
            onRemove: () => _removePhoto(data),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: data.title,
            decoration: const InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Obligatorio' : null,
            onChanged: (value) => _updateForm(_copyData(data)..title = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: data.servings.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Raciones',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed < 1) {
                      return 'Mínimo 1';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      _updateForm(_copyData(data)..servings = parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: data.prepTime?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Prep (min)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final copy = _copyData(data);
                    copy.prepTime = int.tryParse(value);
                    _updateForm(copy);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: data.cookTime?.toString() ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Cocción (min)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final copy = _copyData(data);
                    copy.cookTime = int.tryParse(value);
                    _updateForm(copy);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Etiquetas', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...suggestedRecipeTags.map(
                (tag) => FilterChip(
                  label: Text(tag),
                  selected: data.tags.contains(tag),
                  onSelected: (selected) {
                    final copy = _copyData(data);
                    if (selected) {
                      copy.tags.add(tag);
                    } else {
                      copy.tags.remove(tag);
                    }
                    _updateForm(copy);
                  },
                ),
              ),
              ...data.tags
                  .where((tag) => !suggestedRecipeTags.contains(tag))
                  .map(
                    (tag) => InputChip(
                      label: Text(tag),
                      onDeleted: () {
                        final copy = _copyData(data);
                        copy.tags.remove(tag);
                        _updateForm(copy);
                      },
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
                  final copy = _copyData(data);
                  copy.tags.add(tag);
                  _tagController.clear();
                  _updateForm(copy);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Ingredientes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.ingredients.length,
            onReorderItem: (oldIndex, newIndex) {
              final copy = _copyData(data);
              if (newIndex > oldIndex) newIndex -= 1;
              final item = copy.ingredients.removeAt(oldIndex);
              copy.ingredients.insert(newIndex, item);
              _updateForm(copy);
            },
            itemBuilder: (context, index) {
              final ingredient = data.ingredients[index];
              return IngredientRow(
                key: ValueKey(ingredient.key),
                index: index,
                ingredient: ingredient,
                canRemove: data.ingredients.length > 1,
                onChanged: (updated) {
                  final copy = _copyData(data);
                  copy.ingredients[index] = updated;
                  _updateForm(copy);
                },
                onRemove: () {
                  final copy = _copyData(data);
                  copy.ingredients.removeAt(index);
                  _updateForm(copy);
                },
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                final copy = _copyData(data);
                copy.ingredients.add(IngredientFormItem());
                _updateForm(copy);
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir ingrediente'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Pasos', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.steps.length,
            onReorderItem: (oldIndex, newIndex) {
              final copy = _copyData(data);
              if (newIndex > oldIndex) newIndex -= 1;
              final item = copy.steps.removeAt(oldIndex);
              copy.steps.insert(newIndex, item);
              _updateForm(copy);
            },
            itemBuilder: (context, index) {
              final step = data.steps[index];
              return Card(
                key: ValueKey(step.key),
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
                            index: index,
                            child: Icon(
                              Icons.drag_handle,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: step.description,
                              decoration: InputDecoration(
                                labelText: 'Paso ${index + 1}',
                                isDense: true,
                              ),
                              maxLines: 3,
                              onChanged: (value) {
                                final copy = _copyData(data);
                                copy.steps[index].description = value;
                                _updateForm(copy);
                              },
                            ),
                          ),
                          if (data.steps.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                final copy = _copyData(data);
                                copy.steps.removeAt(index);
                                _updateForm(copy);
                              },
                            ),
                        ],
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text('Opcional'),
                        value: step.isOptional,
                        onChanged: (value) {
                          if (value != null) {
                            final copy = _copyData(data);
                            copy.steps[index].isOptional = value;
                            _updateForm(copy);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                final copy = _copyData(data);
                copy.steps.add(StepFormItem());
                _updateForm(copy);
              },
              icon: const Icon(Icons.add),
              label: const Text('Añadir paso'),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: data.tips,
            decoration: const InputDecoration(
              labelText: 'Consejos',
              hintText: 'Trucos, variaciones o notas útiles',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            onChanged: (value) {
              final copy = _copyData(data);
              copy.tips = value;
              _updateForm(copy);
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Nutrición (por ración)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _NutritionFields(
            data: data.nutrition,
            onChanged: (nutrition) {
              final copy = _copyData(data);
              copy.nutrition.calories = nutrition.calories;
              copy.nutrition.protein = nutrition.protein;
              copy.nutrition.carbohydrates = nutrition.carbohydrates;
              copy.nutrition.fat = nutrition.fat;
              copy.nutrition.fiber = nutrition.fiber;
              _updateForm(copy);
            },
          ),
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
                onChanged: (value) => _togglePublic(data, value),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

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
    final existingUrlAsync = ref.watch(recipePhotoUrlProvider(existingPhotoPath));

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

class _NutritionFields extends StatelessWidget {
  const _NutritionFields({required this.data, required this.onChanged});

  final NutritionFormData data;
  final ValueChanged<NutritionFormData> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _nutritionField('Calorías (kcal)', data.calories, (v) {
          onChanged(NutritionFormData(
            calories: v,
            protein: data.protein,
            carbohydrates: data.carbohydrates,
            fat: data.fat,
            fiber: data.fiber,
          ));
        }),
        _nutritionField('Proteínas (g)', data.protein, (v) {
          onChanged(NutritionFormData(
            calories: data.calories,
            protein: v,
            carbohydrates: data.carbohydrates,
            fat: data.fat,
            fiber: data.fiber,
          ));
        }),
        _nutritionField('Carbohidratos (g)', data.carbohydrates, (v) {
          onChanged(NutritionFormData(
            calories: data.calories,
            protein: data.protein,
            carbohydrates: v,
            fat: data.fat,
            fiber: data.fiber,
          ));
        }),
        _nutritionField('Grasas (g)', data.fat, (v) {
          onChanged(NutritionFormData(
            calories: data.calories,
            protein: data.protein,
            carbohydrates: data.carbohydrates,
            fat: v,
            fiber: data.fiber,
          ));
        }),
        _nutritionField('Fibra (g)', data.fiber, (v) {
          onChanged(NutritionFormData(
            calories: data.calories,
            protein: data.protein,
            carbohydrates: data.carbohydrates,
            fat: data.fat,
            fiber: v,
          ));
        }),
      ],
    );
  }

  Widget _nutritionField(
    String label,
    num? value,
    ValueChanged<num?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        initialValue: value?.toString() ?? '',
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (text) =>
            onChanged(num.tryParse(text.replaceAll(',', '.'))),
      ),
    );
  }
}
