import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:share_plus/share_plus.dart';

/// Shares a recipe as plain text with an HTTPS link (system share sheet).
Future<void> shareRecipeLink(
  BuildContext context, {
  required String title,
  required String url,
}) async {
  final text = context.l10n.shareRecipeMessage(title, url);
  final box = context.findRenderObject() as RenderBox?;
  final origin = box != null
      ? box.localToGlobal(Offset.zero) & box.size
      : const Rect.fromLTWH(0, 0, 1, 1);

  await Share.share(text, sharePositionOrigin: origin);
}
