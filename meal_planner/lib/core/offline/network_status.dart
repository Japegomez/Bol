import 'package:connectivity_plus/connectivity_plus.dart';

abstract final class NetworkStatus {
  static Future<bool> get isOnline async {
    final results = await Connectivity().checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }
}

bool isOfflineFromConnectivity(List<ConnectivityResult>? results) {
  if (results == null) return false;
  return results.isEmpty || results.contains(ConnectivityResult.none);
}
