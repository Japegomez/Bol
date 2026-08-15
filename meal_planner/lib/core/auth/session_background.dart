import 'package:shared_preferences/shared_preferences.dart';

/// Marks when the app was backgrounded so we can expire the session on resume.
abstract final class SessionBackground {
  static const _key = 'meal_planner.session_backgrounded_at';

  /// Sign out when the app returns from background after at least this long.
  ///
  /// Intentionally aligned with Supabase's ~1-week refresh token (not a short
  /// idle timeout). Meal planning leaves the app backgrounded during cooking,
  /// shopping, or overnight; shorter cutoffs (10 min / 12 h) signed users out
  /// mid-flow and broke offline access. After this window, resume forces a
  /// local sign-out; before that, only an invalid refresh token ends the
  /// session.
  static const timeout = Duration(days: 7);

  static Future<void> markBackgrounded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);
  }

  /// Test helper: mark backgrounded at an explicit instant.
  static Future<void> markBackgroundedAt(DateTime at) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, at.millisecondsSinceEpoch);
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
