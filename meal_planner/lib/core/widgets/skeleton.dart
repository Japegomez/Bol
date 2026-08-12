import 'package:flutter/material.dart';

/// Provides a shared pulse animation to descendant [SkeletonBox] widgets.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({required this.child, super.key});

  final Widget child;

  static Animation<double>? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SkeletonPulseScope>()
        ?.animation;
  }

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _controller.stop();
      _controller.value = 0.35;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SkeletonPulseScope(
      animation: _animation,
      child: widget.child,
    );
  }
}

class _SkeletonPulseScope extends InheritedWidget {
  const _SkeletonPulseScope({
    required this.animation,
    required super.child,
  });

  final Animation<double> animation;

  @override
  bool updateShouldNotify(_SkeletonPulseScope oldWidget) {
    return animation != oldWidget.animation;
  }
}

/// Rounded placeholder block that pulses when inside a [SkeletonPulse].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    this.width,
    this.height,
    this.borderRadius,
    super.key,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHigh;
    final animation = SkeletonPulse.of(context);
    final radius = borderRadius ?? BorderRadius.circular(8);

    Widget box(Color color) {
      final decoration = BoxDecoration(
        color: color,
        borderRadius: radius,
      );
      if (width == null && height == null) {
        return DecoratedBox(
          decoration: decoration,
          child: const SizedBox.expand(),
        );
      }
      return SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(decoration: decoration),
      );
    }

    if (animation == null) {
      return box(base);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return box(Color.lerp(base, highlight, animation.value)!);
      },
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({required this.size, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    this.height = 12,
    this.widthFactor = 1,
    super.key,
  });

  final double height;
  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: SkeletonBox(height: height),
      ),
    );
  }
}

/// Repeating list of [item] placeholders with a shared pulse.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    required this.item,
    this.itemCount = 6,
    this.padding = const EdgeInsets.all(16),
    this.physics = const AlwaysScrollableScrollPhysics(),
    super.key,
  });

  final Widget item;
  final int itemCount;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics physics;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SkeletonPulse(
        child: ListView.builder(
          padding: padding,
          physics: physics,
          itemCount: itemCount,
          itemBuilder: (_, _) => item,
        ),
      ),
    );
  }
}

/// Square photo on the left that matches the card's content height.
class RecipeCardRow extends StatelessWidget {
  const RecipeCardRow({
    required this.photo,
    required this.content,
    this.minSize = 96,
    super.key,
  });

  final Widget photo;
  final Widget content;
  final double minSize;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minSize),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: photo),
                ],
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

/// Card matching recipe-book / explore / feed list rows
/// (square photo + title, meta, and tags in the text column).
class RecipeCardSkeleton extends StatelessWidget {
  const RecipeCardSkeleton({
    this.margin = const EdgeInsets.only(bottom: 12),
    this.showTags = false,
    this.showAuthorLine = false,
    super.key,
  });

  final EdgeInsetsGeometry margin;

  /// When true, shows chip placeholders like [HorizontalTagList] beside the photo.
  final bool showTags;

  /// Explore/feed cards also show author + rating next to the photo.
  final bool showAuthorLine;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: margin,
      child: RecipeCardRow(
        photo: const SkeletonBox(borderRadius: BorderRadius.zero),
        content: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonLine(height: 16, widthFactor: 0.85),
              const SizedBox(height: 4),
              SkeletonLine(
                height: 12,
                widthFactor: showAuthorLine ? 0.9 : 0.4,
              ),
              if (showTags) ...[
                const SizedBox(height: 8),
                const _TagChipRowSkeleton(),
              ] else if (!showAuthorLine) ...[
                const SizedBox(height: 8),
                const SkeletonLine(height: 12, widthFactor: 0.55),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChipRowSkeleton extends StatelessWidget {
  const _TagChipRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBox(
          width: 76,
          height: 32,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        SizedBox(width: 4),
        SkeletonBox(
          width: 108,
          height: 32,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        SizedBox(width: 4),
        SkeletonBox(
          width: 64,
          height: 32,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ],
    );
  }
}

class ShoppingListSkeleton extends StatelessWidget {
  const ShoppingListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SkeletonPulse(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 88),
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            _ShoppingGroupSkeleton(itemCount: 4),
            _ShoppingGroupSkeleton(itemCount: 3),
            _ShoppingGroupSkeleton(itemCount: 4),
          ],
        ),
      ),
    );
  }
}

class _ShoppingGroupSkeleton extends StatelessWidget {
  const _ShoppingGroupSkeleton({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SkeletonBox(width: 120, height: 14),
        ),
        for (var i = 0; i < itemCount; i++)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                SkeletonBox(
                  width: 22,
                  height: 22,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(width: 16),
                Expanded(child: SkeletonLine(height: 14, widthFactor: 0.7)),
              ],
            ),
          ),
      ],
    );
  }
}

class PlannerSkeleton extends StatelessWidget {
  const PlannerSkeleton({this.showWeekHeader = true, super.key});

  final bool showWeekHeader;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SkeletonPulse(
        child: Column(
          children: [
            if (showWeekHeader)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 48, height: 48),
                    Expanded(
                      child: Column(
                        children: [
                          SkeletonBox(width: 160, height: 14),
                          SizedBox(height: 6),
                          SkeletonBox(width: 72, height: 10),
                        ],
                      ),
                    ),
                    SizedBox(width: 48, height: 48),
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 88),
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  _PlannerDaySkeleton(),
                  _PlannerDaySkeleton(),
                  _PlannerDaySkeleton(),
                  _PlannerDaySkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerDaySkeleton extends StatelessWidget {
  const _PlannerDaySkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 140, height: 20),
            SizedBox(height: 4),
            _PlannerMealRowSkeleton(),
            _PlannerMealRowSkeleton(),
            _PlannerMealRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _PlannerMealRowSkeleton extends StatelessWidget {
  const _PlannerMealRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: const Row(
        children: [
          SizedBox(
            width: 76,
            child: SkeletonBox(width: 64, height: 14),
          ),
          Expanded(
            child: SkeletonBox(
              height: 32,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

class ListTileSkeleton extends StatelessWidget {
  const ListTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(height: 14, widthFactor: 0.7),
                SizedBox(height: 8),
                SkeletonLine(height: 12, widthFactor: 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeDetailSkeleton extends StatelessWidget {
  const RecipeDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExcludeSemantics(
      child: SkeletonPulse(
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: SkeletonBox(
                height: 220,
                borderRadius: BorderRadius.zero,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLine(height: 22, widthFactor: 0.75),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        SkeletonBox(width: 88, height: 28),
                        SizedBox(width: 8),
                        SkeletonBox(width: 72, height: 28),
                        SizedBox(width: 8),
                        SkeletonBox(width: 64, height: 28),
                      ],
                    ),
                    SizedBox(height: 28),
                    SkeletonBox(width: 140, height: 18),
                    SizedBox(height: 12),
                    SkeletonLine(height: 14, widthFactor: 0.9),
                    SizedBox(height: 8),
                    SkeletonLine(height: 14, widthFactor: 0.8),
                    SizedBox(height: 8),
                    SkeletonLine(height: 14, widthFactor: 0.65),
                    SizedBox(height: 8),
                    SkeletonLine(height: 14, widthFactor: 0.75),
                    SizedBox(height: 28),
                    SkeletonBox(width: 100, height: 18),
                    SizedBox(height: 12),
                    SkeletonLine(height: 14, widthFactor: 1),
                    SizedBox(height: 8),
                    SkeletonLine(height: 14, widthFactor: 0.95),
                    SizedBox(height: 8),
                    SkeletonLine(height: 14, widthFactor: 0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SkeletonPulse(
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            Center(child: SkeletonCircle(size: 96)),
            SizedBox(height: 16),
            Center(child: SkeletonBox(width: 160, height: 20)),
            SizedBox(height: 8),
            Center(child: SkeletonBox(width: 200, height: 14)),
            SizedBox(height: 32),
            ListTileSkeleton(),
            ListTileSkeleton(),
            ListTileSkeleton(),
            ListTileSkeleton(),
            ListTileSkeleton(),
          ],
        ),
      ),
    );
  }
}

class PublicProfileSkeleton extends StatelessWidget {
  const PublicProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SkeletonPulse(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    SkeletonCircle(size: 96),
                    SizedBox(height: 16),
                    SkeletonBox(width: 140, height: 22),
                    SizedBox(height: 8),
                    SkeletonBox(width: 180, height: 14),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, _) => const RecipeCardSkeleton(
                    showTags: true,
                    showAuthorLine: true,
                  ),
                  childCount: 4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HouseholdSkeleton extends StatelessWidget {
  const HouseholdSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SkeletonPulse(
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SkeletonLine(height: 24, widthFactor: 0.55),
            SizedBox(height: 24),
            SkeletonBox(width: 100, height: 16),
            SizedBox(height: 8),
            SkeletonBox(height: 72),
            SizedBox(height: 24),
            SkeletonBox(width: 90, height: 16),
            SizedBox(height: 8),
            ListTileSkeleton(),
            ListTileSkeleton(),
            ListTileSkeleton(),
          ],
        ),
      ),
    );
  }
}

class CompactRecipeRowSkeleton extends StatelessWidget {
  const CompactRecipeRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            SkeletonBox(
              width: 44,
              height: 44,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(height: 12, widthFactor: 0.8),
                  SizedBox(height: 6),
                  SkeletonLine(height: 10, widthFactor: 0.4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FormPhotoSkeleton extends StatelessWidget {
  const FormPhotoSkeleton({this.height = 180, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SkeletonPulse(
        child: SkeletonBox(
          height: height,
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }
}
