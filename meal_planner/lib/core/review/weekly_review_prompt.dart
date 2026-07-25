import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/core/review/review_prompt_service.dart';
import 'package:meal_planner/features/onboarding/presentation/onboarding_provider.dart';

/// Attempts a weekly in-app review prompt once the home shell is visible and
/// onboarding is finished.
class WeeklyReviewPrompt extends ConsumerStatefulWidget {
  const WeeklyReviewPrompt({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<WeeklyReviewPrompt> createState() => _WeeklyReviewPromptState();
}

class _WeeklyReviewPromptState extends ConsumerState<WeeklyReviewPrompt> {
  var _attemptedThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  Future<void> _maybePrompt() async {
    if (!mounted || _attemptedThisSession) return;
    if (ref.read(onboardingCompletedProvider) != true) return;

    _attemptedThisSession = true;
    await ReviewPromptService.maybeRequestReview();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool?>(onboardingCompletedProvider, (previous, next) {
      if (next == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
      }
    });

    return widget.child;
  }
}
