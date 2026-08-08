import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Forwards warning/error log lines to Sentry as breadcrumbs in production builds.
final class SentryLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (!Env.hasSentry || !Env.isProduction) return;
    if (event.level.index < Level.warning.index) return;

    final message = event.lines.join('\n');
    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: 'logger',
        level: switch (event.level) {
          Level.error || Level.fatal => SentryLevel.error,
          Level.warning => SentryLevel.warning,
          _ => SentryLevel.info,
        },
      ),
    );
  }
}

final log = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 100,
    colors: true,
    printEmojis: true,
  ),
  output: MultiOutput([
    // Console output is debug-only: release builds must not write potentially
    // sensitive log lines to the system log (logcat / Console.app).
    if (kDebugMode) ConsoleOutput(),
    SentryLogOutput(),
  ]),
);
