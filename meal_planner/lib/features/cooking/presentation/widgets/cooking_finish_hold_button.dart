import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_session_provider.dart';
import 'package:meal_planner/features/cooking/presentation/cooking_utils.dart';

/// Hold (~1.6s from pointer down) to open the finish-cooking confirmation.
class CookingFinishHoldButton extends StatefulWidget {
  const CookingFinishHoldButton({
    required this.notifier,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
    this.innerSize = 40,
    this.iconSize = 22,
    super.key,
  });

  final CookingSessionNotifier notifier;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double innerSize;
  final double iconSize;

  static const holdDuration = Duration(milliseconds: 1600);

  @override
  State<CookingFinishHoldButton> createState() =>
      _CookingFinishHoldButtonState();
}

class _CookingFinishHoldButtonState extends State<CookingFinishHoldButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CookingFinishHoldButton.holdDuration,
    )..addStatusListener(_onStatus);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _controller.reset();
      confirmFinishCooking(context, widget.notifier);
    }
  }

  void _cancelIfIncomplete() {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = widget.iconColor ?? colorScheme.primary;
    final backgroundColor =
        widget.backgroundColor ?? colorScheme.primaryContainer;
    final label = l10n.finishCookingButton;

    return Semantics(
      button: true,
      label: label,
      onTap: () => confirmFinishCooking(context, widget.notifier),
      child: Tooltip(
        message: label,
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _controller.forward(from: 0),
          onPointerUp: (_) => _cancelIfIncomplete(),
          onPointerCancel: (_) => _controller.reset(),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: widget.innerSize,
                      height: widget.innerSize,
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.stop_rounded,
                        color: iconColor,
                        size: widget.iconSize,
                      ),
                    ),
                    if (progress > 0)
                      SizedBox(
                        width: widget.size,
                        height: widget.size,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 3,
                          color: iconColor,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
