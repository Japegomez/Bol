import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/offline/network_status.dart';
import 'package:meal_planner/features/connectivity/connectivity_notifier.dart';
import 'package:meal_planner/features/household/presentation/household_provider.dart';

final isOfflineProvider = Provider<bool>((ref) {
  if (kIsWeb) return false;

  final connectivity = ref.watch(connectivityProvider);
  return connectivity.maybeWhen(
    data: isOfflineFromConnectivity,
    orElse: () => false,
  );
});

/// True when the user can mutate data while offline (individual mode only).
final canEditOfflineProvider = Provider<bool>((ref) {
  if (!ref.watch(isOfflineProvider)) return true;
  final household = ref.watch(currentHouseholdProvider).valueOrNull;
  return household == null;
});
