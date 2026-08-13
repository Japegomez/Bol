import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInWebButton extends StatelessWidget {
  const GoogleSignInWebButton({
    super.key,
    required this.onSignIn,
    this.enabled = true,
  });

  final Future<void> Function(GoogleSignInAccount user) onSignIn;
  final bool enabled;

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
