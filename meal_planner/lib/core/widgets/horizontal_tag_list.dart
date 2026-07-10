import 'package:flutter/material.dart';

/// Horizontally scrollable chip row for recipe tags inside list cards.
class HorizontalTagList extends StatefulWidget {
  const HorizontalTagList({required this.tags, super.key});

  final List<String> tags;

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
    final offset = (_scrollController.offset - delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    _scrollController.jumpTo(offset);
  }

  void _fling(DragEndDetails details) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final target = (_scrollController.offset -
            details.velocity.pixelsPerSecond.dx * 0.15)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              for (var index = 0; index < widget.tags.length; index++) ...[
                if (index > 0) const SizedBox(width: 4),
                Chip(
                  label: Text(widget.tags[index]),
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
