import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_session_provider.dart';

const _kChannelId = 'cooking_session';
const _kChannelName = 'Cooking session';
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
    await cookingQueueBackgroundAction(actionId);
  }
}

/// Singleton service that manages the persistent "cooking session" notification
/// on Android (and a basic one on iOS).
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
    _initialized = true;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
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
  }

  Future<void> show(CookingSession session) async {
    if (!_initialized) return;
    if (!_isAndroid && !_isIOS) return;

    final stepIndex = session.currentStepIndex;
    final total = session.totalSteps;
    final stepText = stepIndex == 0
        ? 'Comprobar ingredientes'
        : session.steps[stepIndex - 1].description;

    if (_isAndroid) {
      await _showAndroid(session, stepText, stepIndex, total);
    }
    // iOS: the Live Activity replaces the notification on iOS 16.1+.
    // A basic alert-style notification is not shown during active cooking.
  }

  Future<void> cancel() async {
    if (!_initialized) return;
    await _plugin.cancel(_kNotificationId);
  }

  // ── Android ──────────────────────────────────────────────────────────────

  Future<void> _showAndroid(
    CookingSession session,
    String stepText,
    int stepIndex,
    int totalSteps,
  ) async {
    final isPaused = session.isPaused;

    // Chronometer base = now − elapsed = startedAt + accumulatedPauseMs
    final chronometerBase = session.startedAt.millisecondsSinceEpoch +
        session.accumulatedPauseMs;

    final actions = [
      AndroidNotificationAction(
        isPaused ? _kActionResume : _kActionPause,
        isPaused ? 'Continuar' : 'Pausar',
        showsUserInterface: false,
      ),
      const AndroidNotificationAction(
        _kActionFinish,
        'Terminar',
        showsUserInterface: true,
      ),
    ];

    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      channelDescription: 'Session de cocina en curso',
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
        '(${stepIndex + 1}/$totalSteps) $stepText',
        contentTitle: session.recipeTitle,
      ),
      channelShowBadge: false,
    );

    await _plugin.show(
      _kNotificationId,
      session.recipeTitle,
      isPaused
          ? 'Pausada — ${_elapsedLabel(session.elapsed)}'
          : '(${stepIndex + 1}/$totalSteps) $stepText',
      NotificationDetails(android: androidDetails),
    );
  }

  // ── Foreground tap handler ────────────────────────────────────────────────

  // This runs in the main isolate; we dispatch to the provider via the
  // queued-action mechanism to keep the logic in one place.
  Future<void> _onForegroundResponse(NotificationResponse response) async {
    final actionId = response.actionId;
    if (actionId != null) {
      await cookingQueueBackgroundAction(actionId);
      // The provider will pick this up on next lifecycle resume or poll.
      // For an immediate effect when the app is already running, apply now:
      await _applyActionImmediately(actionId);
    }
  }

  // Directly applies the action when the app is already in foreground.
  // The provider singleton is not accessible here (no WidgetRef), so we
  // read from SharedPreferences via the queued-action bridge — but that
  // would wait for a lifecycle event. Instead we expose a static callback.
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
