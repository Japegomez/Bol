import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:meal_planner/core/locale/localized_data.dart';

/// Horizontally scrollable chip row for recipe tags inside list cards.
class HorizontalTagList extends StatefulWidget {
  const HorizontalTagList({required this.tags, this.labelFor, super.key});

  final List<String> tags;

  /// When null, [tags] are treated as tag keys and localized via [localizedTagLabel].
  final String Function(String tag)? labelFor;

  @override
  State<HorizontalTagList> createState() => _HorizontalTagListState();
}

class _HorizontalTagListState extends State<HorizontalTagList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollBy(double delta) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final offset = (_scrollController.offset - delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    _scrollController.jumpTo(offset);
  }

  void _fling(DragEndDetails details) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final target =
        (_scrollController.offset - details.velocity.pixelsPerSecond.dx * 0.15)
            .clamp(position.minScrollExtent, position.maxScrollExtent)
            .toDouble();

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final resolveLabel =
        widget.labelFor ?? (tag) => localizedTagLabel(l10n, tag);
    final tags = sortedRecipeTags(widget.tags);

    return SizedBox(
      height: 32,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) => _scrollBy(details.delta.dx),
        onHorizontalDragEnd: _fling,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              for (var index = 0; index < tags.length; index++) ...[
                if (index > 0) const SizedBox(width: 4),
                Chip(
                  label: Text(resolveLabel(tags[index])),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
