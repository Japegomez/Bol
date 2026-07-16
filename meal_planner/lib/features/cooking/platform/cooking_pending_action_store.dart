import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

const cookingPendingActionKey = 'cooking_pending_action_v1';
const cookingAppGroupId = 'group.com.japegomez.mealPlanner.cooking';

const _kChannelName = 'com.japegomez.mealPlanner/cooking_app_group';

/// Reads/writes the pending cooking action shared with the iOS Live Activity
/// extension (App Group UserDefaults). On Android / web falls back to
/// [SharedPreferences].
class CookingPendingActionStore {
  CookingPendingActionStore._();

  static const _channel = MethodChannel(_kChannelName);

  static bool get _useAppGroup =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static Future<String?> read() async {
    if (_useAppGroup) {
      try {
        final value = await _channel.invokeMethod<String>('getPendingAction');
        return value;
      } catch (_) {
        // Fall through to SharedPreferences if the channel is unavailable.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(cookingPendingActionKey);
  }

  static Future<void> write(String action) async {
    if (_useAppGroup) {
      try {
        await _channel.invokeMethod<void>('setPendingAction', action);
        return;
      } catch (_) {
        // Fall through.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(cookingPendingActionKey, action);
  }

  static Future<void> clear() async {
    if (_useAppGroup) {
      try {
        await _channel.invokeMethod<void>('clearPendingAction');
      } catch (_) {
        // Still clear SharedPreferences fallback.
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(cookingPendingActionKey);
  }
}
