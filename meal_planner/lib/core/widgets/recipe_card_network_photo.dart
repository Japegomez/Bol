import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/widgets/skeleton.dart';

/// Resolves a signed photo URL into the card image, skeleton, or placeholder.
class RecipeCardNetworkPhoto extends StatelessWidget {
  const RecipeCardNetworkPhoto({required this.photoUrl, super.key});

  final AsyncValue<String?> photoUrl;

  @override
  Widget build(BuildContext context) {
    return photoUrl.when(
      data: (url) {
        if (url == null) {
          return const RecipePhotoPlaceholder();
        }
        return CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (_, _) => const RecipeCardPhotoSkeleton(),
          errorWidget: (_, _, _) =>
              const RecipePhotoPlaceholder(child: Icon(Icons.broken_image)),
        );
      },
      loading: () => const RecipeCardPhotoSkeleton(),
      error: (_, _) => const RecipePhotoPlaceholder(),
    );
  }
}

class RecipeCardPhotoSkeleton extends StatelessWidget {
  const RecipeCardPhotoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: SkeletonBox(borderRadius: BorderRadius.zero),
    );
  }
}
