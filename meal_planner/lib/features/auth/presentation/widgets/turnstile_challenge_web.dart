import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/material.dart';
import 'package:meal_planner/core/config/env.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/auth/presentation/widgets/turnstile_language.dart';
import 'package:web/web.dart' as web;

/// Flutter `webview_flutter` has no web implementation, so Turnstile is
/// rendered as a real DOM overlay (Cloudflare's JS widget).
Future<String?> showTurnstileChallenge(BuildContext context) async {
  final l10n = context.l10n;
  final scheme = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final language = turnstileLanguageFor(Localizations.localeOf(context));

  final completer = Completer<String?>();
  web.HTMLElement? overlay;
  String? widgetId;
  JSFunction? keydownHandler;
  JSFunction? focusinHandler;
  final previouslyFocused = web.document.activeElement;
  final foundPane = web.document.querySelector('flt-glass-pane');
  final glassPane = foundPane == null ? null : foundPane as web.HTMLElement;
  final previousPointerEvents = glassPane?.style.pointerEvents;
  glassPane?.style.setProperty('pointer-events', 'none');

  void finish(String? token) {
    if (completer.isCompleted) return;
    final id = widgetId;
    if (id != null) {
      _readTurnstile()?.remove(id);
    }
    final host = overlay;
    if (keydownHandler != null) {
      host?.removeEventListener('keydown', keydownHandler);
    }
    if (focusinHandler != null) {
      web.document.removeEventListener('focusin', focusinHandler);
    }
    host?.remove();
    glassPane?.style.setProperty('pointer-events', previousPointerEvents ?? '');
    if (previouslyFocused != null) {
      (previouslyFocused as web.HTMLElement).focus();
    }
    completer.complete(token);
  }

  overlay = _buildOverlay(
    title: l10n.captchaRequired,
    cancelLabel: l10n.cancel,
    failedLabel: l10n.captchaFailed,
    retryLabel: l10n.retry,
    scheme: scheme,
    onCancel: () => finish(null),
  );
  web.document.body!.append(overlay);

  keydownHandler = ((web.Event event) {
    final host = overlay;
    if (host == null) return;
    _onOverlayKeyDown(host, event, () => finish(null));
  }).toJS;
  focusinHandler = ((web.Event event) {
    final host = overlay;
    final target = event.target;
    if (host != null && target != null && host.contains(target as web.Node)) {
      return;
    }
    if (host != null) _focusCancelButton(host);
  }).toJS;
  overlay.addEventListener('keydown', keydownHandler);
  web.document.addEventListener('focusin', focusinHandler);
  _focusCancelButton(overlay);

  final widgetHost =
      overlay.querySelector('#turnstile-host') as web.HTMLElement;
  final errorHost =
      overlay.querySelector('#turnstile-error') as web.HTMLElement;
  final retryButton =
      overlay.querySelector('#turnstile-retry') as web.HTMLButtonElement;

  void showError() {
    widgetHost.style.display = 'none';
    errorHost.style.display = 'flex';
  }

  retryButton.onclick = (web.Event event) {
    event.preventDefault();
    errorHost.style.display = 'none';
    widgetHost.style.display = 'flex';
    final id = widgetId;
    widgetId = null;
    if (id != null) {
      _readTurnstile()?.remove(id);
    }
    widgetId = _renderWidget(
      host: widgetHost,
      isDark: isDark,
      language: language,
      onSuccess: finish,
      onError: showError,
    );
    if (widgetId == null) showError();
  }.toJS;

  try {
    await _ensureTurnstileScript();
    widgetId = _renderWidget(
      host: widgetHost,
      isDark: isDark,
      language: language,
      onSuccess: finish,
      onError: showError,
    );
    if (widgetId == null) showError();
  } on Object {
    showError();
  }

  return completer.future;
}

String? _renderWidget({
  required web.HTMLElement host,
  required bool isDark,
  required String language,
  required void Function(String? token) onSuccess,
  required void Function() onError,
}) {
  final turnstile = _readTurnstile();
  if (turnstile == null) return null;

  final options = JSObject();
  options.setProperty('sitekey'.toJS, Env.turnstileSiteKey.toJS);
  options.setProperty('theme'.toJS, (isDark ? 'dark' : 'light').toJS);
  options.setProperty('language'.toJS, language.toJS);
  options.setProperty(
    'callback'.toJS,
    ((JSString token) {
      onSuccess(token.toDart);
    }).toJS,
  );
  options.setProperty(
    'error-callback'.toJS,
    (() {
      onError();
    }).toJS,
  );

  final id = turnstile.render(host, options);
  return id.isEmpty ? null : id;
}

_TurnstileJs? _readTurnstile() {
  final value = web.window.getProperty('turnstile'.toJS);
  if (value.isUndefinedOrNull) return null;
  return _TurnstileJs(value as JSObject);
}

Future<void> _ensureTurnstileScript() async {
  if (_readTurnstile() != null) return;

  final existing = web.document.querySelector(
    'script[src*="challenges.cloudflare.com/turnstile"]',
  );
  if (existing != null) {
    await _waitForTurnstile();
    return;
  }

  final loaded = Completer<void>();
  final script = web.HTMLScriptElement()
    ..src =
        'https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit'
    ..async = true;
  script.addEventListener(
    'load',
    ((web.Event _) {
      if (!loaded.isCompleted) loaded.complete();
    }).toJS,
  );
  script.addEventListener(
    'error',
    ((web.Event _) {
      if (!loaded.isCompleted) {
        loaded.completeError(StateError('Failed to load Turnstile'));
      }
    }).toJS,
  );
  web.document.head!.append(script);
  await loaded.future;
  await _waitForTurnstile();
}

Future<void> _waitForTurnstile() async {
  for (var i = 0; i < 50; i++) {
    if (_readTurnstile() != null) return;
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
  throw StateError('Turnstile JS API was not available');
}

web.HTMLElement _buildOverlay({
  required String title,
  required String cancelLabel,
  required String failedLabel,
  required String retryLabel,
  required ColorScheme scheme,
  required VoidCallback onCancel,
}) {
  final overlay = web.HTMLDivElement()
    ..setAttribute('role', 'dialog')
    ..setAttribute('aria-modal', 'true')
    ..tabIndex = -1;
  overlay.style
    ..position = 'fixed'
    ..inset = '0'
    ..zIndex = '2147483000'
    ..display = 'flex'
    ..alignItems = 'center'
    ..justifyContent = 'center'
    ..backgroundColor = 'rgba(0, 0, 0, 0.46)'
    ..pointerEvents = 'auto';

  final card = web.HTMLDivElement();
  card.style
    ..width = 'min(360px, calc(100vw - 48px))'
    ..backgroundColor = _cssRgba(scheme.surfaceContainerHigh)
    ..color = _cssRgba(scheme.onSurface)
    ..borderRadius = '28px'
    ..padding = '24px'
    ..boxShadow = '0 8px 24px rgba(0, 0, 0, 0.32)'
    ..fontFamily = 'Roboto, system-ui, sans-serif';

  final titleEl = web.HTMLHeadingElement.h2()..textContent = title;
  titleEl.style
    ..margin = '0 0 16px'
    ..fontSize = '22px'
    ..fontWeight = '400'
    ..lineHeight = '1.25';

  final host = web.HTMLDivElement()..id = 'turnstile-host';
  host.style
    ..display = 'flex'
    ..justifyContent = 'center'
    ..minHeight = '65px';

  final errorHost = web.HTMLDivElement()..id = 'turnstile-error';
  errorHost.style
    ..display = 'none'
    ..flexDirection = 'column'
    ..alignItems = 'center'
    ..gap = '8px'
    ..minHeight = '65px';

  final errorText = web.HTMLParagraphElement()..textContent = failedLabel;
  errorText.style
    ..margin = '0'
    ..fontSize = '14px'
    ..textAlign = 'center';

  final retry = web.HTMLButtonElement()
    ..id = 'turnstile-retry'
    ..type = 'button'
    ..textContent = retryLabel;
  _styleTextButton(retry, scheme.primary);

  errorHost.append(errorText);
  errorHost.append(retry);

  final actions = web.HTMLDivElement();
  actions.style
    ..display = 'flex'
    ..justifyContent = 'flex-end'
    ..marginTop = '16px';

  final cancel = web.HTMLButtonElement()
    ..id = 'turnstile-cancel'
    ..type = 'button'
    ..textContent = cancelLabel;
  _styleTextButton(cancel, scheme.primary);
  cancel.onclick = (web.Event event) {
    event.preventDefault();
    onCancel();
  }.toJS;
  actions.append(cancel);

  card.append(titleEl);
  card.append(host);
  card.append(errorHost);
  card.append(actions);
  overlay.append(card);

  overlay.addEventListener(
    'click',
    ((web.Event event) {
      if (event.target == overlay) {
        event.preventDefault();
        onCancel();
      }
    }).toJS,
  );

  return overlay;
}

void _focusCancelButton(web.HTMLElement overlay) {
  final cancel = overlay.querySelector('#turnstile-cancel');
  if (cancel != null) {
    (cancel as web.HTMLElement).focus();
  }
}

void _onOverlayKeyDown(
  web.HTMLElement overlay,
  web.Event event,
  VoidCallback onCancel,
) {
  final keyEvent = event as web.KeyboardEvent;
  if (keyEvent.key == 'Escape') {
    keyEvent.preventDefault();
    onCancel();
    return;
  }
  if (keyEvent.key == 'Tab') {
    _trapFocus(overlay, keyEvent);
  }
}

void _trapFocus(web.HTMLElement overlay, web.KeyboardEvent event) {
  final focusable = overlay.querySelectorAll(
    'button, iframe, [tabindex]:not([tabindex="-1"])',
  );
  final length = focusable.length;
  if (length == 0) {
    event.preventDefault();
    overlay.focus();
    return;
  }
  final first = focusable.item(0) as web.HTMLElement;
  final last = focusable.item(length - 1) as web.HTMLElement;
  final active = web.document.activeElement;
  if (event.shiftKey) {
    if (active == first || active == overlay) {
      event.preventDefault();
      last.focus();
    }
  } else if (active == last) {
    event.preventDefault();
    first.focus();
  }
}

void _styleTextButton(web.HTMLButtonElement button, Color color) {
  button.style
    ..background = 'transparent'
    ..border = 'none'
    ..color = _cssRgba(color)
    ..fontSize = '14px'
    ..fontWeight = '500'
    ..letterSpacing = '0.1px'
    ..textTransform = 'uppercase'
    ..cursor = 'pointer'
    ..padding = '10px 12px';
}

String _cssRgba(Color color) {
  final r = (color.r * 255).round();
  final g = (color.g * 255).round();
  final b = (color.b * 255).round();
  return 'rgba($r, $g, $b, ${color.a})';
}

extension type _TurnstileJs(JSObject _) implements JSObject {
  external String render(web.HTMLElement container, JSObject options);
  external void remove(String widgetId);
}
