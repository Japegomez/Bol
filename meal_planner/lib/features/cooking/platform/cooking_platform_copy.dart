import 'dart:ui' show PlatformDispatcher;

import 'package:meal_planner/features/cooking/domain/cooking_session.dart';
import 'package:meal_planner/l10n/app_localizations.dart';

/// Localized copy for Android notifications and iOS Live Activities.
class CookingPlatformCopy {
  const CookingPlatformCopy({
    required this.channelName,
    required this.channelDescription,
    required this.checkIngredientsStep,
    required this.pausedLabel,
    required this.pauseAction,
    required this.resumeAction,
    required this.finishAction,
    required this.stepLabel,
    required this.stepText,
  });

  final String channelName;
  final String channelDescription;
  final String checkIngredientsStep;
  final String pausedLabel;
  final String pauseAction;
  final String resumeAction;
  final String finishAction;
  final String stepLabel;
  final String stepText;

  static CookingPlatformCopy resolve(CookingSession session) {
    final locale = PlatformDispatcher.instance.locale;
    final l10n = lookupAppLocalizations(locale);
    final stepIndex = session.currentStepIndex;
    final stepText = stepIndex == 0
        ? l10n.checkIngredientsStep
        : session.steps[stepIndex - 1].description;

    return CookingPlatformCopy(
      channelName: l10n.cookingNotificationChannelName,
      channelDescription: l10n.cookingNotificationChannelDescription,
      checkIngredientsStep: l10n.checkIngredientsStep,
      pausedLabel: l10n.cookingPausedLabel,
      pauseAction: l10n.cookingPauseTooltip,
      resumeAction: l10n.cookingResumeTooltip,
      finishAction: l10n.finishCookingButton,
      stepLabel: l10n.stepXofY(stepIndex + 1, session.totalSteps),
      stepText: stepText,
    );
  }
}
