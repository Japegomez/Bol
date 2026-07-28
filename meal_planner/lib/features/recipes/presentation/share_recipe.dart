import 'package:flutter/material.dart';
import 'package:meal_planner/core/locale/l10n_extension.dart';
import 'package:share_plus/share_plus.dart';

/// Shares a recipe link. WhatsApp shows the photo via Open Graph on the URL
/// (same model as YouTube link previews), not as an attached file.
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
