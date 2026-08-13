import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Single-line text that scrolls left when it overflows, then jumps back.
///
/// Implemented as a [RenderBox] so it works inside [IntrinsicHeight]
/// (recipe cards). [LayoutBuilder] cannot report intrinsic sizes.
class OverflowMarqueeText extends StatefulWidget {
  const OverflowMarqueeText({required this.text, this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  State<OverflowMarqueeText> createState() => _OverflowMarqueeTextState();
}

class _OverflowMarqueeTextState extends State<OverflowMarqueeText>
    with SingleTickerProviderStateMixin {
  static const _startPause = Duration(milliseconds: 1200);
  static const _endPause = Duration(milliseconds: 800);
  static const _pixelsPerSecond = 36.0;

  late final AnimationController _controller;
  double _overflow = 0;
  double? _syncedOverflow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(OverflowMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.style != widget.style) {
      _syncedOverflow = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncAnimation({
    required double overflow,
    required bool disableAnimations,
  }) {
    if (disableAnimations || overflow <= 1) {
      if (_controller.isAnimating || _controller.value != 0) {
        _controller.stop();
        _controller.value = 0;
      }
      _overflow = 0;
      _syncedOverflow = overflow;
      return;
    }

    if (_syncedOverflow == overflow && _controller.isAnimating) return;

    _overflow = overflow;
    _syncedOverflow = overflow;
    final scrollMs = (overflow / _pixelsPerSecond * 1000)
        .round()
        .clamp(600, 10000)
        .toInt();
    _controller
      ..duration = _startPause + Duration(milliseconds: scrollMs) + _endPause
      ..repeat();
  }

  double _dx(double t) {
    final totalMs = _controller.duration?.inMilliseconds ?? 1;
    final startT = _startPause.inMilliseconds / totalMs;
    final endT = 1.0 - _endPause.inMilliseconds / totalMs;
    if (t <= startT) return 0;
    if (t >= endT) return -_overflow;
    final progress = (t - startT) / (endT - startT);
    return -_overflow * progress;
  }

  void _onOverflow(double overflow, bool disableAnimations) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncAnimation(overflow: overflow, disableAnimations: disableAnimations);
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? DefaultTextStyle.of(context).style;
    final disableAnimations = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return _MarqueeText(
            text: widget.text,
            style: style,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
            disableAnimations: disableAnimations,
            scrollOffset: _dx(_controller.value),
            onOverflow: (overflow) => _onOverflow(overflow, disableAnimations),
          );
        },
      ),
    );
  }
}

class _MarqueeText extends LeafRenderObjectWidget {
  const _MarqueeText({
    required this.text,
    required this.style,
    required this.textDirection,
    required this.textScaler,
    required this.disableAnimations,
    required this.scrollOffset,
    required this.onOverflow,
  });

  final String text;
  final TextStyle style;
  final TextDirection textDirection;
  final TextScaler textScaler;
  final bool disableAnimations;
  final double scrollOffset;
  final ValueChanged<double> onOverflow;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMarqueeText(
      text: text,
      style: style,
      textDirection: textDirection,
      textScaler: textScaler,
      disableAnimations: disableAnimations,
      scrollOffset: scrollOffset,
      onOverflow: onOverflow,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMarqueeText renderObject,
  ) {
    renderObject
      ..text = text
      ..style = style
      ..textDirection = textDirection
      ..textScaler = textScaler
      ..disableAnimations = disableAnimations
      ..scrollOffset = scrollOffset
      ..onOverflow = onOverflow;
  }
}

class _RenderMarqueeText extends RenderBox {
  _RenderMarqueeText({
    required this._text,
    required this._style,
    required this._textDirection,
    required this._textScaler,
    required this._disableAnimations,
    required this._scrollOffset,
    required this.onOverflow,
  }) {
    _rebuildPainter();
  }

  TextPainter? _painter;
  TextPainter? _clippedPainter;
  String? _clippedText;
  TextStyle? _clippedStyle;
  TextDirection? _clippedDirection;
  TextScaler? _clippedScaler;
  double? _clippedWidth;
  String _text;
  TextStyle _style;
  TextDirection _textDirection;
  TextScaler _textScaler;
  bool _disableAnimations;
  double _scrollOffset;
  ValueChanged<double> onOverflow;

  set text(String value) {
    if (_text == value) return;
    _text = value;
    _rebuildPainter();
    markNeedsLayout();
  }

  set style(TextStyle value) {
    if (_style == value) return;
    _style = value;
    _rebuildPainter();
    markNeedsLayout();
  }

  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    _rebuildPainter();
    markNeedsLayout();
  }

  set textScaler(TextScaler value) {
    if (_textScaler == value) return;
    _textScaler = value;
    _rebuildPainter();
    markNeedsLayout();
  }

  set disableAnimations(bool value) {
    if (_disableAnimations == value) return;
    _disableAnimations = value;
    markNeedsLayout();
    markNeedsPaint();
  }

  set scrollOffset(double value) {
    if (_scrollOffset == value) return;
    _scrollOffset = value;
    markNeedsPaint();
  }

  void _rebuildPainter() {
    _painter?.dispose();
    _painter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      maxLines: 1,
      ellipsis: '…',
      textDirection: _textDirection,
      textScaler: _textScaler,
    )..layout();
    _invalidateClippedPainter();
  }

  void _invalidateClippedPainter() {
    _clippedPainter?.dispose();
    _clippedPainter = null;
    _clippedText = null;
    _clippedStyle = null;
    _clippedDirection = null;
    _clippedScaler = null;
    _clippedWidth = null;
  }

  TextPainter _ensureClippedPainter() {
    if (_clippedPainter != null &&
        _clippedText == _text &&
        _clippedStyle == _style &&
        _clippedDirection == _textDirection &&
        _clippedScaler == _textScaler &&
        _clippedWidth == size.width) {
      return _clippedPainter!;
    }
    _clippedPainter?.dispose();
    _clippedPainter = TextPainter(
      text: TextSpan(text: _text, style: _style),
      maxLines: 1,
      ellipsis: '…',
      textDirection: _textDirection,
      textScaler: _textScaler,
    )..layout(maxWidth: size.width);
    _clippedText = _text;
    _clippedStyle = _style;
    _clippedDirection = _textDirection;
    _clippedScaler = _textScaler;
    _clippedWidth = size.width;
    return _clippedPainter!;
  }

  TextPainter get _textPainter => _painter!;

  double get _lineHeight {
    final height = _textPainter.height;
    if (height > 0) return height;
    return (_style.fontSize ?? 14) * (_style.height ?? 1.2);
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => _textPainter.width;

  @override
  double computeMinIntrinsicHeight(double width) => _lineHeight;

  @override
  double computeMaxIntrinsicHeight(double width) => _lineHeight;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : _textPainter.width;
    return constraints.constrain(Size(width, _lineHeight));
  }

  @override
  void performLayout() {
    final width = constraints.maxWidth.isFinite
        ? constraints.maxWidth
        : _textPainter.width;
    size = constraints.constrain(Size(width, _lineHeight));
    final overflow = constraints.maxWidth.isFinite
        ? _textPainter.width - size.width
        : 0.0;
    onOverflow(overflow);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final overflow = _textPainter.width - size.width;
    context.canvas.save();
    context.canvas.clipRect(offset & size);
    if (_disableAnimations && overflow > 1) {
      _ensureClippedPainter().paint(context.canvas, offset);
    } else {
      _textPainter.paint(context.canvas, offset.translate(_scrollOffset, 0));
    }
    context.canvas.restore();
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void dispose() {
    _painter?.dispose();
    _clippedPainter?.dispose();
    super.dispose();
  }
}
