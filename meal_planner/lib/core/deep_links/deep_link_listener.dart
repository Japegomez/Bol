import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_share_provider.dart';
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
    final shareUri = _normalizeShareUri(uri);
    if (shareUri == null) return;

    final auth = ref.read(authStateProvider).valueOrNull;
    final isAuthenticated = auth is AuthAuthenticated;
    if (!isAuthenticated) {
      ref.read(pendingShareLinkProvider.notifier).state = shareUri;
      return;
    }

    await _navigateForShareUri(shareUri);
  }

  /// Accepts HTTPS Hosting links and `recetea://r|p/...` fallbacks from the landing page.
  Uri? _normalizeShareUri(Uri uri) {
    if (_isShareHost(uri)) return uri;

    if (uri.scheme == 'recetea') {
      final host = uri.host;
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if ((host == 'r' || host == 'p') && segments.isNotEmpty) {
        return Uri(
          scheme: 'https',
          host: ShareUrls.host,
          pathSegments: [host, segments.first],
        );
      }
      if (segments.length >= 2 && (segments[0] == 'r' || segments[0] == 'p')) {
        return Uri(
          scheme: 'https',
          host: ShareUrls.host,
          pathSegments: segments.take(2).toList(),
        );
      }
    }
    return null;
  }

  bool _isShareHost(Uri uri) {
    final host = uri.host.toLowerCase();
    return host == ShareUrls.host ||
        host == 'mealplanner-a818e.firebaseapp.com';
  }

  Future<void> _navigateForShareUri(Uri uri) async {
    if (_handling) return;
    _handling = true;
    try {
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length < 2) return;

      final kind = segments[0];
      final value = segments[1];
      final router = ref.read(routerProvider);

      if (kind == 'p') {
        router.go('/home/explore/$value');
        return;
      }

      if (kind == 'r') {
        try {
          final recipeId = await ref
              .read(recipeShareRepositoryProvider)
              .resolvePrivateShareToken(value);
          router.go('/home/recipes/$recipeId');
        } catch (e) {
          log.w('Failed to resolve share token: $e');
          router.go('/home/recipes');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final ctx = rootNavigatorKey.currentContext;
            if (ctx == null || !ctx.mounted) return;
            final l10n = ctx.l10n;
            final message = e.toString().toLowerCase().contains('expired')
                ? l10n.shareLinkExpired
                : l10n.shareLinkInvalid;
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(message)),
            );
          });
        }
      }
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
          unawaited(_navigateForShareUri(pending));
        }
      }
    });

    return widget.child;
  }
}
