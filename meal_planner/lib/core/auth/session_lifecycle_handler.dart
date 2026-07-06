import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Placeholder for lifecycle-based session management.
/// The session is kept alive as long as Supabase can silently refresh the
/// token (refresh_token valid ~1 week). The user is only redirected to login
/// when the refresh token expires or they sign out manually.
class SessionLifecycleHandler extends ConsumerWidget {
  const SessionLifecycleHandler({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => child;
}
