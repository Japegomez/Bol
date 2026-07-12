import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

abstract final class NetworkStatus {
  static const _connectivityTimeout = Duration(seconds: 3);

  static Future<bool> get isOnline async {
    try {
      final results = await Connectivity()
          .checkConnectivity()
          .timeout(_connectivityTimeout);
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } on TimeoutException {
      return false;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }
}

bool isOfflineFromConnectivity(List<ConnectivityResult>? results) {
  if (results == null) return false;
  return results.isEmpty || results.contains(ConnectivityResult.none);
}
