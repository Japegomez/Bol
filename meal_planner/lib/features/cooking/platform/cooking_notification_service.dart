import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/platform/cooking_platform_copy.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_session_provider.dart';

const _kChannelId = 'cooking_session';
const _kNotificationId = 0;

const _kActionPause = 'pause';
const _kActionResume = 'resume';
const _kActionFinish = 'finish';

/// Called from a background isolate when a notification action button is tapped
/// while the app is not in the foreground.
@pragma('vm:entry-point')
Future<void> onNotificationBackground(NotificationResponse response) async {
  final actionId = response.actionId;
  if (actionId == null) return;

  if (actionId == _kActionPause ||
      actionId == _kActionResume ||
      actionId == _kActionFinish) {
    await cookingApplyBackgroundAction(actionId);
  }
}

/// Manages the persistent cooking-session notification.
///
/// • Android: ongoing notification with chronometer, action buttons, BigText.
/// • iOS: passive local notification in the notification centre (no sound/badge).
///   The lock screen is covered by the Live Activity (CookingLiveActivityService).
class CookingNotificationService {
  CookingNotificationService._();

  static final CookingNotificationService instance =
      CookingNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get _isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!_isAndroid && !_isIOS) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        // Do not request permissions here — we request them below so we can
        // use the platform-specific API and ask only for alerts (no sound/badge).
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onForegroundResponse,
        onDidReceiveBackgroundNotificationResponse: onNotificationBackground,
      );

      if (_isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      if (_isIOS) {
        // Request only alert permission — no sound, no badge — so the
        // notification appears passively in the notification centre.
        await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: false, sound: false);
      }

      _initialized = true;
    } catch (e) {
      log.w('CookingNotificationService init failed: $e');
      _initialized = false;
    }
  }

  Future<void> show(CookingSession session) async {
    if (!_initialized) {
      await initialize();
      if (!_initialized) return;
    }

    final copy = CookingPlatformCopy.resolve(session);

    if (_isAndroid) {
      await _showAndroid(session, copy);
    } else if (_isIOS) {
      // Show a passive notification in the notification centre.
      // The lock screen is handled by the Live Activity.
      await _showIOS(session, copy);
    }
  }

  Future<void> cancel() async {
    if (!_initialized) return;
    await _plugin.cancel(_kNotificationId);
  }

  // ── Android ────────────────────────────────────────────────────────────────

  Future<void> _showAndroid(
    CookingSession session,
    CookingPlatformCopy copy,
  ) async {
    final isPaused = session.isPaused;
    final chronometerBase = session.startedAt.millisecondsSinceEpoch +
        session.accumulatedPauseMs;

    final actions = [
      AndroidNotificationAction(
        isPaused ? _kActionResume : _kActionPause,
        isPaused ? copy.resumeAction : copy.pauseAction,
        showsUserInterface: false,
      ),
      AndroidNotificationAction(
        _kActionFinish,
        copy.finishAction,
        showsUserInterface: true,
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      copy.channelName,
      channelDescription: copy.channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: true,
      when: isPaused ? null : chronometerBase,
      usesChronometer: !isPaused,
      chronometerCountDown: false,
      visibility: NotificationVisibility.public,
      actions: actions,
      styleInformation: BigTextStyleInformation(
        '${copy.stepLabel}\n${copy.stepText}',
        contentTitle: session.recipeTitle,
      ),
      channelShowBadge: false,
    );

    await _plugin.show(
      _kNotificationId,
      session.recipeTitle,
      isPaused
          ? '${copy.pausedLabel} — ${_elapsedLabel(session.elapsed)}'
          : '${copy.stepLabel}: ${copy.stepText}',
      NotificationDetails(android: androidDetails),
    );
  }

  // ── iOS ────────────────────────────────────────────────────────────────────

  Future<void> _showIOS(
    CookingSession session,
    CookingPlatformCopy copy,
  ) async {
    // Passive interruption level: no sound, no banner alert while the device
    // is unlocked — the notification just appears in the notification centre.
    // The lock screen is handled by the Live Activity.
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false, // suppress foreground banner; notification still lands in centre
      presentBadge: false,
      presentSound: false,
      interruptionLevel: InterruptionLevel.passive,
    );

    final body = session.isPaused
        ? '${copy.pausedLabel} · ${_elapsedLabel(session.elapsed)}'
        : '${copy.stepLabel} · ${copy.stepText}';

    await _plugin.show(
      _kNotificationId,
      session.recipeTitle,
      body,
      const NotificationDetails(iOS: iosDetails),
    );
  }

  // ── Shared ─────────────────────────────────────────────────────────────────

  Future<void> _onForegroundResponse(NotificationResponse response) async {
    final actionId = response.actionId;
    if (actionId != null) {
      await _applyActionImmediately(actionId);
    }
  }

  static Future<void> Function(String)? _directActionCallback;

  static void setDirectActionCallback(
    Future<void> Function(String) callback,
  ) {
    _directActionCallback = callback;
  }

  Future<void> _applyActionImmediately(String actionId) async {
    await _directActionCallback?.call(actionId);
  }
}

String _elapsedLabel(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
