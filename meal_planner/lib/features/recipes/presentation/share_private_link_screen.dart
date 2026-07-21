import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/recipes/presentation/recipe_share_provider.dart';

/// Resolves a private share token then replaces with the recipe detail route.
class SharePrivateLinkScreen extends ConsumerStatefulWidget {
  const SharePrivateLinkScreen({required this.token, super.key});

  final String token;

  @override
  ConsumerState<SharePrivateLinkScreen> createState() =>
      _SharePrivateLinkScreenState();
}

class _SharePrivateLinkScreenState
    extends ConsumerState<SharePrivateLinkScreen> {
  Object? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    try {
      final recipeId = await ref
          .read(recipeShareRepositoryProvider)
          .resolvePrivateShareToken(widget.token);
      if (!mounted) return;
      context.go('/home/recipes/$recipeId');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_error != null) {
      final message = _error.toString().toLowerCase().contains('expired')
          ? l10n.shareLinkExpired
          : l10n.shareLinkInvalid;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/home/recipes'),
                  child: Text(l10n.closeTooltip),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
