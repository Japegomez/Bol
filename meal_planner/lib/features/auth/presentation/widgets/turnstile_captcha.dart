import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/config/share_urls.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Cloudflare Turnstile widget for email auth (login, register, reset).
///
/// The WebView origin must match the hostname allowlisted on the Turnstile
/// widget: [ShareUrls.host].
class TurnstileCaptcha extends StatefulWidget {
  const TurnstileCaptcha({
    required this.onTokenChanged,
    this.resetEpoch = 0,
    super.key,
  });

  final ValueChanged<String?> onTokenChanged;

  /// Increment to reload the challenge after a failed auth attempt.
  final int resetEpoch;

  static const height = 68.0;

  @override
  State<TurnstileCaptcha> createState() => _TurnstileCaptchaState();
}

class _TurnstileCaptchaState extends State<TurnstileCaptcha> {
  WebViewController? _controller;
  String? _theme;
  var _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    if (_controller == null || _theme != theme) {
      _theme = theme;
      _initController();
    }
  }

  @override
  void didUpdateWidget(TurnstileCaptcha oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetEpoch != widget.resetEpoch) {
      widget.onTokenChanged(null);
      _loadHtml();
    }
  }

  void _initController() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..addJavaScriptChannel(
        'Turnstile',
        onMessageReceived: (message) {
          if (!mounted) return;
          _onChannelMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme == 'about') return NavigationDecision.navigate;
            final host = uri.host.toLowerCase();
            if (host == ShareUrls.host ||
                host == 'challenges.cloudflare.com' ||
                host.endsWith('.cloudflare.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );
    _controller = controller;
    _loadHtml(notifyParent: false);
  }

  void _loadHtml({bool notifyParent = true}) {
    final controller = _controller;
    if (controller == null || !Env.hasTurnstile) return;
    _failed = false;
    if (notifyParent) {
      widget.onTokenChanged(null);
      if (mounted) setState(() {});
    }
    controller.loadHtmlString(
      _html(siteKey: Env.turnstileSiteKey, theme: _theme ?? 'auto'),
      baseUrl: 'https://${ShareUrls.host}/',
    );
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
      if (mounted) setState(() => _failed = false);
      widget.onTokenChanged(token != null && token.isNotEmpty ? token : null);
      return;
    }
    if (event == 'expired') {
      widget.onTokenChanged(null);
      return;
    }
    if (event == 'error') {
      if (mounted) setState(() => _failed = true);
      widget.onTokenChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Env.hasTurnstile) {
      return const SizedBox.shrink();
    }

    final controller = _controller;
    if (controller == null) {
      return const SizedBox(height: TurnstileCaptcha.height);
    }

    if (_failed) {
      return SizedBox(
        height: TurnstileCaptcha.height,
        child: Center(
          child: TextButton(
            onPressed: _loadHtml,
            child: Text(context.l10n.retry),
          ),
        ),
      );
    }

    return SizedBox(
      height: TurnstileCaptcha.height,
      width: double.infinity,
      child: WebViewWidget(controller: controller),
    );
  }

  static String _html({required String siteKey, required String theme}) {
    final key = const HtmlEscape().convert(siteKey);
    final safeTheme = theme == 'dark' ? 'dark' : 'light';
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
  <script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
  <style>
    html, body { margin: 0; padding: 0; background: transparent; overflow: hidden; }
    .wrap { display: flex; justify-content: center; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="cf-turnstile"
         data-sitekey="$key"
         data-callback="onSuccess"
         data-error-callback="onError"
         data-expired-callback="onExpired"
         data-theme="$safeTheme"></div>
  </div>
  <script>
    function onSuccess(token) {
      Turnstile.postMessage(JSON.stringify({event: 'success', token: token}));
    }
    function onError() {
      Turnstile.postMessage(JSON.stringify({event: 'error'}));
    }
    function onExpired() {
      Turnstile.postMessage(JSON.stringify({event: 'expired'}));
    }
  </script>
</body>
</html>
''';
  }
}
