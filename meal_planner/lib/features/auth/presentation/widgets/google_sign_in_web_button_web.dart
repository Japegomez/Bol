import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;
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
  StreamSubscription<GoogleSignInAuthenticationEvent>? _subscription;
  var _ready = false;

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
      ) {
        if (event is GoogleSignInAuthenticationEventSignIn) {
          widget.onSignIn(event.user);
        }
      });
      setState(() => _ready = true);
    } on Object {
      if (mounted) setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: google_web.renderButton(),
      ),
    );
  }
}
