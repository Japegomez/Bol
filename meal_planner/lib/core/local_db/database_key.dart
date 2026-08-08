import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the per-install encryption key for the local drift database.
///
/// The key is generated once, stored in the platform keystore/keychain via
/// flutter_secure_storage, and reused across launches. Losing the key (e.g.
/// after a factory reset or OS keychain wipe) means the local database can
/// no longer be decrypted; the app must recreate it from the server.
abstract final class DatabaseKey {
  static const _key = 'meal_planner.db_key';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Returns the existing key, or creates and persists a new 256-bit key.
  static Future<String> getOrCreate() async {
    final existing = await _storage.read(key: _key);
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64Url.encode(bytes);
    await _storage.write(key: _key, value: key);
    return key;
  }
}
