import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meal_planner/core/config/legal_urls.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({
    required this.title,
    required this.url,
    super.key,
  });

  final String title;
  final String url;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  WebViewController? _controller;
  var _isLoading = true;
  String? _error;

  /// Only hosts in this set may render inside the WebView. Anything else
  /// (ads, redirects, OAuth, etc.) is blocked and handed to the external
  /// browser so untrusted content can't run in-process.
  static final _allowedHosts = {
    Uri.parse(LegalUrls.base).host,
  };

  bool _isAllowed(Uri uri) {
    final host = uri.host;
    for (final allowed in _allowedHosts) {
      if (host == allowed || host.endsWith('.$allowed')) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _openExternally();
      return;
    }
    // Never load an untrusted URL into the WebView even on startup.
    if (!_isAllowed(Uri.parse(widget.url))) {
      _openExternally();
      return;
    }
    _initWebView();
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(widget.url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (launched) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isLoading = false;
        _error = context.l10n.couldNotOpenDocument;
      });
    }
  }

  void _initWebView() {
    final controller = WebViewController()
      // Legal docs are static HTML; no JavaScript needed.
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = error.description;
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null || !_isAllowed(uri)) {
              // Redirect disallowed navigations to the system browser.
              launchUrl(Uri.parse(request.url),
                  mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.allow;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => launchUrl(
              Uri.parse(widget.url),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_browser),
            tooltip: l10n.openInBrowser,
          ),
        ],
      ),
      body: kIsWeb
          ? Center(
              child: _error != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!),
                    )
                  : const CircularProgressIndicator(),
            )
          : Stack(
              children: [
                if (_controller != null)
                  WebViewWidget(controller: _controller!),
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!),
                    ),
                  ),
              ],
            ),
    );
  }
}
