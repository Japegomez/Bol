import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:meal_planner/core/local_db/database_key.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens the local drift database encrypted with SQLCipher (via
/// SQLite3MultipleCiphers). The encryption key is kept in the platform
/// keystore; a one-time migration re-encrypts any pre-existing plaintext
/// database so existing offline data is preserved.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'recetea_offline.sqlite'));
    final key = await DatabaseKey.getOrCreate();
    await _migrateLegacyPlaintextToEncrypted(file, key);
    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        _debugCheckHasCipher(rawDb);
        rawDb.execute("PRAGMA key = '${_escape(key)}';");
      },
    );
  });
}

/// Asserts that the bundled SQLite actually supports encryption. With
/// SQLite3MultipleCiphers the `cipher` pragma returns the active cipher name;
/// plain SQLite returns no rows for the unknown pragma.
void _debugCheckHasCipher(Database db) {
  assert(() {
    final rows = db.select('PRAGMA cipher;');
    if (rows.isEmpty) {
      throw StateError(
        'Local database is not encrypted: the bundled SQLite has no cipher '
        'support. Ensure `hooks.user_defines.sqlite3.source = sqlite3mc` '
        'is set in pubspec.yaml.',
      );
    }
    return true;
  }());
}

/// Re-encrypts a legacy plaintext database in place. No-op when the database
/// is already encrypted or doesn't exist yet.
///
/// PRAGMA key cannot encrypt a plaintext file in place, so we open the
/// plaintext file, ATTACH a new encrypted database, run sqlcipher_export,
/// then replace the old file. The drift schema version (user_version) is
/// carried over so drift doesn't re-run migrations on the copied data.
Future<void> _migrateLegacyPlaintextToEncrypted(File file, String key) async {
  if (!file.existsSync()) return;

  // Try to read the file as plaintext. An encrypted file opened without a
  // key fails here ("file is not a database"), which is how we tell the two
  // apart.
  Database? plain;
  try {
    plain = sqlite3.open(file.path);
    plain.select('SELECT count(*) FROM sqlite_master');
  } catch (_) {
    plain?.close();
    return; // Already encrypted (or unreadable) — leave it as-is.
  }

  final tmpPath = '${file.path}.enc';
  final tmpFile = File(tmpPath);
  if (tmpFile.existsSync()) tmpFile.deleteSync();

  try {
    final userVersion =
        plain.select('PRAGMA user_version;').first.columnAt(0) as int;
    plain.execute(
      "ATTACH DATABASE '${_escape(tmpPath)}' AS encrypted KEY '${_escape(key)}';",
    );
    plain.execute("SELECT sqlcipher_export('encrypted');");
    plain.execute('DETACH DATABASE encrypted;');
    plain.close();
    plain = null;

    // Stamp the schema version onto the new encrypted file.
    final enc = sqlite3.open(tmpPath)
      ..execute("PRAGMA key = '${_escape(key)}';")
      ..execute('PRAGMA user_version = $userVersion;');
    enc.close();

    // Promote via backup so a failed rename can restore the original DB.
    final backupPath = '${file.path}.bak';
    final backupFile = File(backupPath);
    if (backupFile.existsSync()) backupFile.deleteSync();

    try {
      file.renameSync(backupPath);
      tmpFile.renameSync(file.path);
      backupFile.deleteSync();
    } catch (_) {
      // Restore original if promotion failed mid-way.
      if (!file.existsSync() && backupFile.existsSync()) {
        backupFile.renameSync(file.path);
      }
      if (tmpFile.existsSync()) tmpFile.deleteSync();
      rethrow;
    }
  } catch (e) {
    // Migration failed — fall back to opening the existing file (plain or
    // otherwise) and let drift surface a real error if it can't be read.
    plain?.close();
    if (tmpFile.existsSync()) tmpFile.deleteSync();
    // Intentionally swallow: the caller will open the DB and report issues.
  }
}

String _escape(String s) => s.replaceAll("'", "''");
