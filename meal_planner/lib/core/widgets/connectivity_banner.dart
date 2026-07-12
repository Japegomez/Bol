import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/features/connectivity/connectivity_notifier.dart';

/// Persistent offline banner shown as a [MaterialBanner] inside the nearest
/// [Scaffold]. Sits below the AppBar so it never covers titles or buttons.
class ConnectivityBanner extends ConsumerWidget {
  const ConnectivityBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final isOffline = !kIsWeb &&
        connectivity.maybeWhen(
          data: (results) =>
              results.isEmpty || results.contains(ConnectivityResult.none),
          orElse: () => false,
        );

    return _OfflineBannerListener(isOffline: isOffline, child: child);
  }
}

class _OfflineBannerListener extends StatefulWidget {
  const _OfflineBannerListener({
    required this.isOffline,
    required this.child,
  });

  final bool isOffline;
  final Widget child;

  @override
  State<_OfflineBannerListener> createState() => _OfflineBannerListenerState();
}

class _OfflineBannerListenerState extends State<_OfflineBannerListener> {
  @override
  void didUpdateWidget(covariant _OfflineBannerListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isOffline == widget.isOffline) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncBanner());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncBanner());
  }

  void _syncBanner() {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.clearMaterialBanners();
    if (widget.isOffline) {
      messenger.showMaterialBanner(
        MaterialBanner(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          leading: const Icon(Icons.wifi_off, color: Colors.white, size: 18),
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Sin conexión',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white),
          ),
          actions: const [SizedBox.shrink()],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
