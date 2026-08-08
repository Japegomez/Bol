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

  static String? _cached;
  static Future<String>? _inflight;

  /// Returns the existing key, or creates and persists a new 256-bit key.
  /// Concurrent callers share a single in-flight Future so only one
  /// initialization generates and writes the key.
  static Future<String> getOrCreate() {
    if (_cached != null) return Future.value(_cached);
    return _inflight ??= _getOrCreate();
  }

  static Future<String> _getOrCreate() async {
    try {
      final existing = await _storage.read(key: _key);
      if (existing != null && existing.isNotEmpty) {
        _cached = existing;
        return existing;
      }

      final random = Random.secure();
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      final key = base64Url.encode(bytes);
      await _storage.write(key: _key, value: key);
      _cached = key;
      return key;
    } catch (e) {
      _inflight = null;
      rethrow;
    }
  }
}
