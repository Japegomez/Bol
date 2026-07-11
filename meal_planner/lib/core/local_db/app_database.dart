import 'package:drift/drift.dart';
import 'package:meal_planner/core/local_db/database_connection.dart';
import 'package:meal_planner/core/local_db/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalRecipes,
    LocalIngredients,
    LocalRecipeSteps,
    LocalNutritionInfo,
    LocalWeeklyPlans,
    LocalPlanSlots,
    LocalShoppingLists,
    LocalShoppingItems,
    PendingOperations,
    IdMappings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
