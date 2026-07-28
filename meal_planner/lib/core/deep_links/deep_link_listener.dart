import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds a pending share deep link until the user is authenticated.
final pendingShareLinkProvider = StateProvider<Uri?>((ref) => null);

/// Persists pending share links across cold starts / process death.
abstract final class PendingShareLinkStore {
  static const _key = 'meal_planner.pending_share_link';

  static Future<void> save(Uri uri) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, uri.toString());
  }

  static Future<Uri?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    return Uri.tryParse(raw);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  StreamSubscription<Uri>? _sub;
  final _appLinks = AppLinks();
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final stored = await PendingShareLinkStore.load();
      if (stored != null && ShareUrls.appLocationForIncomingUri(stored) != null) {
        ref.read(pendingShareLinkProvider.notifier).state = stored;
      }
    } catch (e) {
      log.w('Failed to restore pending deep link: $e');
    }

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        // Fresh cold-start link supersedes any restored pending URI.
        ref.read(pendingShareLinkProvider.notifier).state = null;
        await PendingShareLinkStore.clear();
        await _onUri(initial);
      }
    } catch (e) {
      log.w('Failed to read initial deep link: $e');
    }

    // If we restored a pending link and the user is already signed in, navigate.
    await _consumePendingIfAuthenticated();

    _sub = _appLinks.uriLinkStream.listen(
      _onUri,
      onError: (Object e) {
        log.w('Deep link stream error: $e');
      },
    );
  }

  Future<void> _onUri(Uri uri) async {
    final location = ShareUrls.appLocationForIncomingUri(uri);
    if (location == null) return;

    final authAsync = ref.read(authStateProvider);
    // Auth still loading — stash and wait for the auth listener.
    if (authAsync.isLoading && !authAsync.hasValue) {
      await _storePending(uri);
      return;
    }

    final isAuthenticated = authAsync.valueOrNull is AuthAuthenticated;
    if (!isAuthenticated) {
      await _storePending(uri);
      return;
    }

    await _navigateTo(location);
  }

  Future<void> _storePending(Uri uri) async {
    ref.read(pendingShareLinkProvider.notifier).state = uri;
    await PendingShareLinkStore.save(uri);
  }

  Future<void> _consumePendingIfAuthenticated() async {
    final auth = ref.read(authStateProvider).valueOrNull;
    if (auth is! AuthAuthenticated) return;

    final pending = ref.read(pendingShareLinkProvider);
    if (pending == null) return;

    final location = ShareUrls.appLocationForIncomingUri(pending);
    if (location == null) return;

    ref.read(pendingShareLinkProvider.notifier).state = null;
    await PendingShareLinkStore.clear();
    await _navigateTo(location);
  }

  Future<void> _navigateTo(String location) async {
    if (_handling) return;
    _handling = true;
    try {
      // Wait until the first frame so GoRouter is attached.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      ref.read(routerProvider).go(location);
    } finally {
      _handling = false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (prev, next) {
      final wasAuth = prev?.valueOrNull is AuthAuthenticated;
      final isAuth = next.valueOrNull is AuthAuthenticated;
      if (!wasAuth && isAuth) {
        final pending = ref.read(pendingShareLinkProvider);
        if (pending == null) return;

        // While still on /auth/*, GoRouter redirect owns the pending link so
        // we do not race and send the user to the planner first.
        final matched = ref.read(routerProvider).state.matchedLocation;
        if (matched.startsWith('/auth')) return;

        ref.read(pendingShareLinkProvider.notifier).state = null;
        unawaited(PendingShareLinkStore.clear());
        final location = ShareUrls.appLocationForIncomingUri(pending);
        if (location != null) {
          unawaited(_navigateTo(location));
        }
      }
    });

    return widget.child;
  }
}
