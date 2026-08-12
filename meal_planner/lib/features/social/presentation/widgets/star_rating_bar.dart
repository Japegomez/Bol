import 'package:flutter/material.dart';

class StarRatingBar extends StatelessWidget {
  const StarRatingBar({
    required this.rating,
    this.onRatingChanged,
    this.size = 24,
    this.readOnly = false,
    super.key,
  });

  final double rating;
  final ValueChanged<int>? onRatingChanged;
  final double size;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final filled = rating >= starValue - 0.25;
        return IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: size, minHeight: size),
          visualDensity: VisualDensity.compact,
          onPressed: readOnly || onRatingChanged == null
              ? null
              : () => onRatingChanged!(starValue),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled
                ? Colors.amber
                : Theme.of(context).colorScheme.outline,
            size: size,
          ),
        );
      }),
    );
  }
}

class StarRatingDisplay extends StatelessWidget {
  const StarRatingDisplay({
    required this.rating,
    this.count,
    this.size = 16,
    super.key,
  });

  final double rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: size),
        const SizedBox(width: 4),
        Text(
          rating > 0 ? rating.toStringAsFixed(1) : '—',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }
}
