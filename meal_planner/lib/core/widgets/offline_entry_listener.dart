import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/offline/can_edit_offline_provider.dart';
import 'package:meal_planner/core/widgets/offline_limitations_dialog.dart';
import 'package:meal_planner/features/auth/domain/auth_state.dart';
import 'package:meal_planner/features/auth/presentation/auth_provider.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';

/// Tracks whether the offline limitations dialog was shown for the current
/// offline session (resets when connectivity returns).
final offlineDialogShownProvider = StateProvider<bool>((ref) => false);

/// Shows [OfflineLimitationsDialog] once when the user enters the app offline.
class OfflineEntryListener extends ConsumerStatefulWidget {
  const OfflineEntryListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<OfflineEntryListener> createState() =>
      _OfflineEntryListenerState();
}

class _OfflineEntryListenerState extends ConsumerState<OfflineEntryListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDialog());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeShowDialog();
    }
  }

  void _maybeShowDialog() {
    if (!mounted) return;

    final isOffline = ref.read(isOfflineProvider);
    if (!isOffline) return;

    final authState = ref.read(authStateProvider).valueOrNull;
    if (authState is! AuthAuthenticated) return;

    if (ref.read(offlineDialogShownProvider)) return;

    ref.read(offlineDialogShownProvider.notifier).state = true;

    final inHousehold =
        ref.read(currentHouseholdProvider).valueOrNull != null;

    showOfflineLimitationsDialog(
      context,
      inHousehold: inHousehold,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isOfflineProvider, (previous, next) {
      if (previous == true && next == false) {
        // Came back online — reset so the dialog can show again next time.
        ref.read(offlineDialogShownProvider.notifier).state = false;
        return;
      }
      // Became offline (including the first emission that is true on startup).
      if (next == true && previous != true) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDialog());
      }
    });

    return widget.child;
  }
}
