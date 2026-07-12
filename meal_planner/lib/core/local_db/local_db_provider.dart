import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/local_db/app_database.dart';
import 'package:meal_planner/core/local_db/local_cache_store.dart';

final appDatabaseProvider = Provider<AppDatabase?>((ref) {
  if (kIsWeb) return null;

  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final localCacheStoreProvider = Provider<LocalCacheStore>((ref) {
  final db = ref.watch(appDatabaseProvider);
  if (db == null) return LocalCacheStore.disabled();
  return LocalCacheStore(db);
});
