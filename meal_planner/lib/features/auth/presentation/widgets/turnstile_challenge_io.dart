import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/auth/presentation/widgets/turnstile_language.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

/// Native apps have no public hostname. Cloudflare sees this page's host:
/// [ShareUrls.host] (`mealplanner-a818e.web.app`).
Future<String?> showTurnstileChallenge(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (routeContext) => const _TurnstileChallengePage(),
    ),
  );
}

class _TurnstileChallengePage extends StatefulWidget {
  const _TurnstileChallengePage();

  @override
  State<_TurnstileChallengePage> createState() =>
      _TurnstileChallengePageState();
}

class _TurnstileChallengePageState extends State<_TurnstileChallengePage> {
  static const _challengeTimeout = Duration(seconds: 20);

  WebViewController? _controller;
  Timer? _responseTimeout;
  var _failed = false;
  var _unsupported = false;
  var _notConfigured = false;
  var _scheduledInit = false;
  var _pageHandled = false;

  Uri get _challengeUri {
    final theme = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    return Uri.https(ShareUrls.host, '/turnstile.html', {
      'sitekey': Env.turnstileSiteKey,
      'theme': theme,
      'lang': turnstileLanguageFor(Localizations.localeOf(context)),
    });
  }

  @override
  void dispose() {
    _cancelTimeout();
    super.dispose();
  }

  void _armTimeout() {
    _responseTimeout?.cancel();
    _responseTimeout = Timer(_challengeTimeout, () {
      if (!mounted) return;
      setState(() => _failed = true);
    });
  }

  void _cancelTimeout() {
    _responseTimeout?.cancel();
    _responseTimeout = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleInit();
  }

  void _scheduleInit() {
    if (_scheduledInit) return;
    _scheduledInit = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _controller != null) return;
      if (!Env.hasTurnstile) {
        setState(() => _notConfigured = true);
        return;
      }
      try {
        _initController();
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _loadChallenge();
        });
      } on Object {
        setState(() => _unsupported = true);
      }
    });
  }

  void _initController() {
    final surface = Theme.of(context).colorScheme.surface;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(surface)
      ..addJavaScriptChannel(
        'Turnstile',
        onMessageReceived: (message) {
          if (!mounted) return;
          _onChannelMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: _onPageFinished,
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) {
              _cancelTimeout();
              if (mounted) setState(() => _failed = true);
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'about' ||
                uri.scheme == 'data' ||
                uri.scheme == 'blob') {
              return NavigationDecision.navigate;
            }
            if (uri.scheme != 'https') return NavigationDecision.prevent;
            final host = uri.host.toLowerCase();
            if (host.isEmpty) return NavigationDecision.prevent;
            if (host == ShareUrls.host ||
                host == ShareUrls.firebaseHost ||
                host == 'challenges.cloudflare.com') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );
    _enableAndroidCookies(controller);
    _controller = controller;
  }

  void _enableAndroidCookies(WebViewController controller) {
    final webView = controller.platform;
    if (webView is! AndroidWebViewController) return;
    final cookies = WebViewCookieManager().platform;
    if (cookies is AndroidWebViewCookieManager) {
      cookies.setAcceptThirdPartyCookies(webView, true);
    }
  }

  void _loadChallenge() {
    final controller = _controller;
    if (controller == null) return;
    if (!Env.hasTurnstile) {
      setState(() => _notConfigured = true);
      return;
    }
    _pageHandled = false;
    setState(() {
      _failed = false;
      _notConfigured = false;
    });
    _armTimeout();
    controller.loadRequest(_challengeUri);
  }

  Future<void> _onPageFinished(String url) async {
    if (_pageHandled || !mounted) return;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.toLowerCase() != ShareUrls.host) return;

    _pageHandled = true;
    final controller = _controller;
    if (controller == null) return;

    try {
      // Hosted public/turnstile.html must set window.__bolTurnstilePage.
      final marker = await controller.runJavaScriptReturningResult(
        'window.__bolTurnstilePage === true',
      );
      if (_isJsTrue(marker)) return;
      _cancelTimeout();
      if (mounted) setState(() => _failed = true);
    } on Object {
      _cancelTimeout();
      if (mounted) setState(() => _failed = true);
    }
  }

  bool _isJsTrue(Object result) {
    if (result == true) return true;
    final value = result.toString().toLowerCase();
    return value == 'true' || value == '"true"';
  }

  void _onChannelMessage(String raw) {
    Map<String, dynamic>? payload;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) payload = decoded;
    } on Object {
      payload = null;
    }
    final event = payload?['event'] as String?;
    if (event == 'success') {
      final token = payload?['token'] as String?;
      if (token != null && token.isNotEmpty && mounted) {
        _cancelTimeout();
        Navigator.of(context).pop(token);
      }
      return;
    }
    if (event == 'error' && mounted) {
      _cancelTimeout();
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.captchaRequired),
        leading: CloseButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final l10n = context.l10n;
    if (_notConfigured) {
      return Center(
        child: Text(l10n.turnstileNotConfigured, textAlign: TextAlign.center),
      );
    }
    if (_unsupported || _failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.captchaFailed, textAlign: TextAlign.center),
            if (!_unsupported) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: _loadChallenge, child: Text(l10n.retry)),
            ],
          ],
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: WebViewWidget(controller: controller),
    );
  }
}
