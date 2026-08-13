import 'package:flutter/material.dart';
import 'package:meal_planner/core/config/env.dart';

import 'turnstile_challenge_io.dart'
    if (dart.library.js_interop) 'turnstile_challenge_web.dart'
    as challenge;

/// Shows Turnstile and returns a token, or null if cancelled.
Future<String?> showTurnstileChallenge(BuildContext context) {
  if (!Env.hasTurnstile) return Future<String?>.value(null);
  return challenge.showTurnstileChallenge(context);
}
