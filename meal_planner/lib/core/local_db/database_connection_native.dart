import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meal_planner/core/local_db/database_key.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens the local drift database encrypted with SQLCipher (via
/// SQLite3MultipleCiphers). The encryption key is kept in the platform
/// keystore; a one-time migration re-encrypts any pre-existing plaintext
/// database so existing offline data is preserved.
///
/// If the file cannot be opened (wrong key, failed migration, corruption),
/// the local cache is deleted and recreated empty — it is rebuilt from the
/// server on the next sync.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'recetea_offline.sqlite'));
    final key = await DatabaseKey.getOrCreate();

    return NativeDatabase.createInBackground(
      file,
      isolateSetup: () async {
        await _prepareDatabaseFile(file, key);
      },
      setup: (rawDb) {
        _ensureHasCipher(rawDb);
        rawDb.execute("PRAGMA key = '${_escape(key)}';");
        // Fail fast in setup if the key does not unlock the file.
        rawDb.execute('SELECT count(*) FROM sqlite_master');
      },
    );
  });
}

/// Throws when the bundled SQLite has no encryption support (plain SQLite).
void _ensureHasCipher(Database db) {
  final rows = db.select('PRAGMA cipher;');
  if (rows.isEmpty) {
    throw StateError(
      'Local database encryption unavailable: the bundled SQLite has no '
      'cipher support. Ensure `hooks.user_defines.sqlite3.source = sqlite3mc` '
      'is set in pubspec.yaml and that the release build includes native assets.',
    );
  }
}

/// Ensures [file] is either absent, already encrypted with [key], or migrated
/// from a legacy plaintext database. Deletes the file when it is unreadable.
Future<void> _prepareDatabaseFile(File file, String key) async {
  if (!await file.exists()) return;

  if (_canOpenEncrypted(file, key)) return;

  if (_isPlaintextDatabase(file)) {
    try {
      await _migratePlaintextToEncrypted(file, key);
      if (_canOpenEncrypted(file, key)) return;
    } catch (e, st) {
      log.w('Offline DB encryption migration failed: $e', error: e, stackTrace: st);
    }
  }

  // Wrong key, corrupt file, or failed migration — drop the cache.
  log.w('Resetting unreadable offline database at ${file.path}');
  await _deleteDatabaseFiles(file);
}

bool _canOpenEncrypted(File file, String key) {
  Database? db;
  try {
    db = sqlite3.open(file.path);
    _ensureHasCipher(db);
    db.execute("PRAGMA key = '${_escape(key)}';");
    db.select('SELECT count(*) FROM sqlite_master');
    return true;
  } catch (_) {
    return false;
  } finally {
    db?.close();
  }
}

bool _isPlaintextDatabase(File file) {
  Database? db;
  try {
    db = sqlite3.open(file.path);
    // Opening without a key: succeeds for plaintext, fails for encrypted.
    db.select('SELECT count(*) FROM sqlite_master');
    return true;
  } catch (_) {
    return false;
  } finally {
    db?.close();
  }
}

/// Migrates a plaintext SQLite file to an encrypted one using the approach
/// recommended by Drift: `VACUUM INTO` a temp copy, then `PRAGMA rekey`.
Future<void> _migratePlaintextToEncrypted(File file, String key) async {
  final tmpPath = '${file.path}.enc.tmp';
  final tmpFile = File(tmpPath);
  if (await tmpFile.exists()) await tmpFile.delete();

  final plaintextDb = sqlite3.open(file.path);
  try {
    plaintextDb.execute("VACUUM INTO '${_escape(tmpPath)}';");
  } finally {
    plaintextDb.close();
  }

  final encryptedDb = sqlite3.open(tmpPath);
  try {
    _ensureHasCipher(encryptedDb);
    encryptedDb.execute("PRAGMA rekey = '${_escape(key)}';");
  } finally {
    encryptedDb.close();
  }

  final backupPath = '${file.path}.bak';
  final backupFile = File(backupPath);
  if (await backupFile.exists()) await backupFile.delete();

  // Promote the encrypted database. If this fails, roll back.
  try {
    await file.rename(backupPath);
    await tmpFile.rename(file.path);
  } catch (_) {
    if (!await file.exists() && await backupFile.exists()) {
      await backupFile.rename(file.path);
    }
    if (await tmpFile.exists()) await tmpFile.delete();
    rethrow;
  }

  // Migration successful. Clean up the old backup and stale sidecars.
  // If cleanup fails, just log a warning — don't fail the migration.
  try {
    await backupFile.delete();
    await _deleteSidecars(file);
  } catch (e, st) {
    log.w('Failed to clean up after DB migration: $e', error: e, stackTrace: st);
  }
}

Future<void> _deleteDatabaseFiles(File file) async {
  if (await file.exists()) await file.delete();
  await _deleteSidecars(file);
}

Future<void> _deleteSidecars(File file) async {
  for (final suffix in ['-wal', '-shm', '-journal', '.enc.tmp', '.bak', '.enc']) {
    final side = File('${file.path}$suffix');
    if (await side.exists()) {
      try {
        await side.delete();
      } catch (_) {}
    }
  }
}

String _escape(String s) => s.replaceAll("'", "''");
