import 'package:drift/drift.dart';

class LocalRecipes extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get photoUrl => text().nullable()();
  IntColumn get servings => integer()();
  IntColumn get prepTime => integer().nullable()();
  IntColumn get cookTime => integer().nullable()();
  TextColumn get tagsJson => text()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  TextColumn get tips => text().nullable()();
  TextColumn get forkedFromId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalIngredients extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get position => integer()();
  BoolColumn get isOptional =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isIncluded => boolean().withDefault(const Constant(true))();
  BoolColumn get isToTaste =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalRecipeSteps extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  IntColumn get position => integer()();
  TextColumn get description => text()();
  BoolColumn get isOptional =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalNutritionInfo extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()();
  RealColumn get calories => real().nullable()();
  RealColumn get protein => real().nullable()();
  RealColumn get carbohydrates => real().nullable()();
  RealColumn get fat => real().nullable()();
  RealColumn get fiber => real().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalWeeklyPlans extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text().nullable()();
  TextColumn get userId => text().nullable()();
  TextColumn get weekStart => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalPlanSlots extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text()();
  IntColumn get dayOfWeek => integer()();
  TextColumn get mealType => text()();
  TextColumn get recipeId => text().nullable()();
  TextColumn get recipeTitle => text().nullable()();
  IntColumn get servings => integer()();
  IntColumn get position => integer()();
  BoolColumn get isLeftover =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalShoppingLists extends Table {
  TextColumn get id => text()();
  TextColumn get householdId => text().nullable()();
  TextColumn get userId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalShoppingItems extends Table {
  TextColumn get id => text()();
  TextColumn get shoppingListId => text()();
  TextColumn get name => text()();
  RealColumn get quantity => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get category => text().nullable()();
  BoolColumn get isChecked =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isManual =>
      boolean().withDefault(const Constant(false))();
  TextColumn get planSlotId => text().nullable()();
  TextColumn get ingredientId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PendingOperations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get entityType => text()();
  TextColumn get opType => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class IdMappings extends Table {
  TextColumn get tempId => text()();
  TextColumn get realId => text()();

  @override
  Set<Column<Object>> get primaryKey => {tempId};
}
