import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/auth/session_background.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/supabase/supabase_client.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

/// Expires the session after a long background period (~7 days, aligned with
/// the Supabase refresh token) and revalidates the JWT on resume.
class SessionLifecycleHandler extends ConsumerStatefulWidget {
  const SessionLifecycleHandler({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SessionLifecycleHandler> createState() =>
      _SessionLifecycleHandlerState();
}

class _SessionLifecycleHandlerState
    extends ConsumerState<SessionLifecycleHandler>
    with WidgetsBindingObserver {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool get _isAuthenticated {
    final auth = ref.read(authStateProvider).valueOrNull;
    return auth is AuthAuthenticated;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Env.hasSupabase) return;

    // Only [paused]: [inactive] also fires for control center / app switcher
    // glances and would keep rewriting the background timestamp unnecessarily.
    if (state == AppLifecycleState.paused) {
      if (_isAuthenticated && !ref.read(authOperationInProgressProvider)) {
        unawaited(SessionBackground.markBackgrounded());
      }
      return;
    }

    if (state == AppLifecycleState.resumed) {
      // Native OAuth sheets resume the app before login finally clears this flag.
      if (ref.read(authOperationInProgressProvider)) return;
      unawaited(_expireOrRevalidate());
    }
  }

  Future<void> _expireOrRevalidate() async {
    if (_checking || !Env.hasSupabase) return;
    if (!_isAuthenticated) {
      await SessionBackground.clearMarker();
      return;
    }

    _checking = true;
    try {
      final expired = await SessionBackground.isExpiredAfterBackground();
      await SessionBackground.clearMarker();

      if (expired) {
        log.i('Session expired after background timeout');
        await ref.read(authRepositoryProvider).signOut();
        return;
      }

      await _revalidateSession();
    } catch (e) {
      log.w('Session resume check failed: $e');
    } finally {
      _checking = false;
    }
  }

  /// Forces a server round-trip; local sign-out on hard auth failure only
  /// (network errors keep the session so offline use still works).
  Future<void> _revalidateSession() async {
    try {
      await supabase.auth.getUser();
    } on AuthException catch (e) {
      if (_isTransientNetworkError(e)) return;
      log.i('Session invalid on resume: ${e.message}');
      try {
        await ref
            .read(authRepositoryProvider)
            .signOut(scope: SignOutScope.local);
      } catch (_) {
        // Storage may already be inconsistent.
      }
    } catch (e) {
      if (_isTransientNetworkMessage('$e')) return;
      log.w('Unexpected session revalidation error: $e');
    }
  }

  bool _isTransientNetworkError(AuthException error) {
    return _isTransientNetworkMessage(error.message);
  }

  bool _isTransientNetworkMessage(String message) {
    final msg = message.toLowerCase();
    return RegExp(
      r'network|fetch|offline|timeout|failed to fetch|socket|econnreset|enotfound|host lookup|name resolution',
    ).hasMatch(msg);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
