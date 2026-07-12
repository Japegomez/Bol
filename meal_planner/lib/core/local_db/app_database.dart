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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(
              pendingOperations,
              pendingOperations.userId,
            );
          }
        },
      );
}
