import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/router/app_router.dart';

/// Holds a pending share deep link until the user is authenticated.
final pendingShareLinkProvider = StateProvider<Uri?>((ref) => null);

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
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _onUri(initial);
      }
    } catch (e) {
      log.w('Failed to read initial deep link: $e');
    }

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

    final auth = ref.read(authStateProvider).valueOrNull;
    final isAuthenticated = auth is AuthAuthenticated;
    if (!isAuthenticated) {
      ref.read(pendingShareLinkProvider.notifier).state = uri;
      return;
    }

    await _navigateTo(location);
  }

  Future<void> _navigateTo(String location) async {
    if (_handling) return;
    _handling = true;
    try {
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
        if (pending != null) {
          ref.read(pendingShareLinkProvider.notifier).state = null;
          final location = ShareUrls.appLocationForIncomingUri(pending);
          if (location != null) {
            unawaited(_navigateTo(location));
          }
        }
      }
    });

    return widget.child;
  }
}
