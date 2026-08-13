import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;
import 'package:meal_planner/core/utils/logger.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';

class GoogleSignInWebButton extends ConsumerStatefulWidget {
  const GoogleSignInWebButton({
    super.key,
    required this.onSignIn,
    this.enabled = true,
  });

  final Future<void> Function(GoogleSignInAccount user) onSignIn;
  final bool enabled;

  @override
  ConsumerState<GoogleSignInWebButton> createState() =>
      _GoogleSignInWebButtonState();
}

class _GoogleSignInWebButtonState extends ConsumerState<GoogleSignInWebButton> {
  static const _buttonHeight = 40.0;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  var _ready = false;
  var _failed = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      await ref.read(authRepositoryProvider).ensureGoogleInitialized();
      if (!mounted) return;
      _subscription = GoogleSignIn.instance.authenticationEvents.listen((
        event,
      ) async {
        if (event is! GoogleSignInAuthenticationEventSignIn) return;
        try {
          await widget.onSignIn(event.user);
        } on Object catch (error, stackTrace) {
          log.e(
            'Google Sign-In web callback failed',
            error: error,
            stackTrace: stackTrace,
          );
        }
      });
      setState(() => _ready = true);
    } on Object catch (error, stackTrace) {
      log.e(
        'Google Sign-In web initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const SizedBox.shrink();
    }
    if (!_ready) {
      return const SizedBox(
        height: _buttonHeight,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (!widget.enabled) {
      return const SizedBox(height: _buttonHeight);
    }

    return google_web.renderButton();
  }
}
