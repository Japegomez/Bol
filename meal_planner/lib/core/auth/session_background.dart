import 'package:shared_preferences/shared_preferences.dart';

/// Marks when the app was backgrounded so we can expire the session on resume.
abstract final class SessionBackground {
  static const _key = 'meal_planner.session_backgrounded_at';

  /// Sign out when the app returns from background after at least this long.
  ///
  /// Intentionally 12 hours (not a short idle timeout). Meal planning often
  /// leaves the app backgrounded during cooking or shopping; a ~10-minute
  /// cutoff signed users out mid-flow. 12 hours still bounds the unattended
  /// access window on a leftover unlocked session, without competing with
  /// Supabase's ~1-week refresh token.
  static const timeout = Duration(hours: 12);

  static Future<void> markBackgrounded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> clearMarker() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<bool> isExpiredAfterBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final backgroundedAt = prefs.getInt(_key);
    if (backgroundedAt == null) return false;
    final elapsed = DateTime.now().millisecondsSinceEpoch - backgroundedAt;
    return elapsed >= timeout.inMilliseconds;
  }
}
