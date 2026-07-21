import 'package:image_picker/image_picker.dart';
import 'package:meal_planner/core/locale/localized_data.dart';
import 'package:meal_planner/features/recipes/domain/unit_mappings.dart';

int _formItemKeyCounter = 0;
String _newFormItemKey(String prefix) => '$prefix-${_formItemKeyCounter++}';

class IngredientFormItem {
  IngredientFormItem({
    String? key,
    this.name = '',
    this.quantity,
    this.unit = defaultIngredientUnit,
    this.category = defaultIngredientCategoryKey,
    this.customUnit = '',
    this.useCustomUnit = false,
    this.isOptional = false,
    this.isIncluded = true,
    this.isToTaste = false,
  }) : key = key ?? _newFormItemKey('ingredient');

  final String key;
  String name;
  num? quantity;
  String? unit;
  String category;
  String customUnit;
  bool useCustomUnit;
  bool isOptional;
  bool isIncluded;
  bool isToTaste;

  String? get effectiveUnit =>
      useCustomUnit ? (customUnit.trim().isEmpty ? null : customUnit.trim()) : unit;

  IngredientFormItem copyWith({
    String? name,
    num? quantity,
    String? unit,
    String? category,
    String? customUnit,
    bool? useCustomUnit,
    bool? isOptional,
    bool? isIncluded,
    bool? isToTaste,
  }) {
    return IngredientFormItem(
      key: key,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      customUnit: customUnit ?? this.customUnit,
      useCustomUnit: useCustomUnit ?? this.useCustomUnit,
      isOptional: isOptional ?? this.isOptional,
      isIncluded: isIncluded ?? this.isIncluded,
      isToTaste: isToTaste ?? this.isToTaste,
    );
  }
}

class StepFormItem {
  StepFormItem({
    String? key,
    this.description = '',
    this.isOptional = false,
  }) : key = key ?? _newFormItemKey('step');

  final String key;
  String description;
  bool isOptional;
}

class NutritionFormData {
  NutritionFormData({
    this.calories,
    this.protein,
    this.carbohydrates,
    this.fat,
    this.fiber,
  });

  num? calories;
  num? protein;
  num? carbohydrates;
  num? fat;
  num? fiber;

  bool get hasAnyValue =>
      calories != null ||
      protein != null ||
      carbohydrates != null ||
      fat != null ||
      fiber != null;

  /// Payload for the recipe assistant when re-estimating nutrition.
  Map<String, int?>? toAssistantPayload() {
    if (!hasAnyValue) return null;
    return {
      'calories': calories?.round(),
      'protein': protein?.round(),
      'carbohydrates': carbohydrates?.round(),
      'fat': fat?.round(),
      'fiber': fiber?.round(),
    };
  }
}

class RecipeFormData {
  RecipeFormData({
    this.title = '',
    this.servings = 4,
    this.prepTime,
    this.cookTime,
    List<String>? tags,
    List<IngredientFormItem>? ingredients,
    List<StepFormItem>? steps,
    NutritionFormData? nutrition,
    this.existingPhotoPath,
    this.removePhoto = false,
    this.pendingPhoto,
    this.isPublic = false,
    this.forkedFromId,
    this.tips = '',
  })  : tags = tags ?? [],
        ingredients = ingredients ?? [IngredientFormItem()],
        steps = steps ?? [StepFormItem()],
        nutrition = nutrition ?? NutritionFormData();

  String title;
  int servings;
  int? prepTime;
  int? cookTime;
  final List<String> tags;
  final List<IngredientFormItem> ingredients;
  final List<StepFormItem> steps;
  final NutritionFormData nutrition;
  String? existingPhotoPath;
  bool removePhoto;
  XFile? pendingPhoto;
  bool isPublic;
  final String? forkedFromId;
  String tips;

  bool get canPublish => forkedFromId == null;

  String? validate() {
    if (title.trim().isEmpty) return 'El nombre es obligatorio';
    if (servings < 1) return 'Las raciones deben ser al menos 1';

    final requiredIngredients = validIngredients.where(
      (ingredient) => !ingredient.isOptional && !ingredient.isToTaste,
    );
    if (requiredIngredients.isEmpty) {
      return 'Añade al menos un ingrediente no opcional';
    }

    final requiredSteps =
        validSteps.where((step) => !step.isOptional);
    if (requiredSteps.isEmpty) {
      return 'Añade al menos un paso de elaboración no opcional';
    }

    return null;
  }

  List<IngredientFormItem> get validIngredients => ingredients
      .where((ingredient) => ingredient.name.trim().isNotEmpty)
      .toList();

  List<StepFormItem> get validSteps =>
      steps.where((step) => step.description.trim().isNotEmpty).toList();
}
