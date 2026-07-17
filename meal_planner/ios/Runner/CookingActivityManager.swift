import ActivityKit
import Foundation

/// Manages `CookingActivityAttributes` Live Activities directly via ActivityKit.
///
/// Exposed to Flutter through the `com.japegomez.mealPlanner/live_activity`
/// MethodChannel registered in `SceneDelegate`.  Using a direct ActivityKit call
/// (instead of the `live_activities` Flutter plugin) ensures the activity is
/// created with **our** `CookingActivityAttributes` type, which is the exact type
/// our `CookingActivityWidget` listens for in the extension.
@available(iOS 16.2, *)
actor CookingActivityManager {

  static let shared = CookingActivityManager()
  private init() {}

  private var activeActivity: Activity<CookingActivityAttributes>?

  private let kAppGroupId = "group.com.japegomez.mealPlanner.cooking"

  // MARK: – Public API

  /// Create-or-update the single cooking Live Activity.
  /// Saves all step texts/labels to the shared App Group so intents can navigate steps
  /// without waiting for Flutter to resume. Preserves the user's text-expanded state
  /// as long as the step index has not changed.
  func update(data: [String: Any]) async throws {
    // Persist step data to App Group so intents can read it.
    let defaults = UserDefaults(suiteName: kAppGroupId)
    if let texts = data["allStepTexts"] as? [String] {
      defaults?.set(texts, forKey: "cooking_all_step_texts")
    }
    if let labels = data["allStepLabels"] as? [String] {
      defaults?.set(labels, forKey: "cooking_all_step_labels")
    }

    let (attrs, unpackedState) = try unpack(data)
    var state = unpackedState

    if let activity = activeActivity {
      let currentState = activity.content.state
      // Keep the user's expand/collapse choice unless the step changed.
      if currentState.stepIndex == state.stepIndex {
        state.isTextExpanded = currentState.isTextExpanded
      }
      await activity.update(ActivityContent(state: state, staleDate: nil))
    } else {
      let activity = try Activity<CookingActivityAttributes>.request(
        attributes: attrs,
        content: ActivityContent(state: state, staleDate: nil),
        pushType: nil
      )
      activeActivity = activity
    }
  }

  /// End all cooking Live Activities immediately.
  func end() async {
    if let activity = activeActivity {
      await activity.end(nil, dismissalPolicy: .immediate)
      activeActivity = nil
    }
  }

  // MARK: – Private helpers

  private func unpack(
    _ d: [String: Any]
  ) throws -> (CookingActivityAttributes, CookingActivityAttributes.CookingContentState) {
    let attrs = CookingActivityAttributes(recipeTitle: (d["recipeTitle"] as? String) ?? "")

    let state = CookingActivityAttributes.CookingContentState(
      stepIndex:          try int(d, "stepIndex"),
      totalSteps:         try int(d, "totalSteps"),
      stepText:           try str(d, "stepText"),
      isPaused:           try boo(d, "isPaused"),
      startedAtMs:        try int(d, "startedAtMs"),
      accumulatedPauseMs: try int(d, "accumulatedPauseMs"),
      pausedAtMs:         d["pausedAtMs"] as? Int,
      pausedLabel:        try str(d, "pausedLabel"),
      stepLabel:          try str(d, "stepLabel"),
      pauseAction:        try str(d, "pauseAction"),
      resumeAction:       try str(d, "resumeAction"),
      finishAction:       try str(d, "finishAction"),
      isTextExpanded:     false
    )
    return (attrs, state)
  }

  private func int(_ d: [String: Any], _ key: String) throws -> Int {
    guard let v = d[key] as? Int else { throw err("Missing Int for key '\(key)'") }
    return v
  }

  private func str(_ d: [String: Any], _ key: String) throws -> String {
    guard let v = d[key] as? String else { throw err("Missing String for key '\(key)'") }
    return v
  }

  private func boo(_ d: [String: Any], _ key: String) throws -> Bool {
    guard let v = d[key] as? Bool else { throw err("Missing Bool for key '\(key)'") }
    return v
  }

  private func err(_ msg: String) -> NSError {
    NSError(
      domain: "CookingActivityManager",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey: msg]
    )
  }
}
