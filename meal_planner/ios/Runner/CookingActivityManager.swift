import ActivityKit
import Foundation

/// Manages `CookingActivityAttributes` Live Activities directly via ActivityKit.
///
/// Exposed to Flutter through the `com.japegomez.mealPlanner/live_activity`
/// MethodChannel registered in `SceneDelegate`.  Using a direct ActivityKit call
/// (instead of the `live_activities` Flutter plugin) ensures the activity is
/// created with **our** `CookingActivityAttributes` type, which is the exact type
/// our `CookingActivityWidget` listens for in the extension.
@available(iOS 16.1, *)
final class CookingActivityManager {

  static let shared = CookingActivityManager()
  private init() {}

  // MARK: – Public API

  /// Create-or-update the single cooking Live Activity.
  /// If no activity is running a new one is started; otherwise the existing
  /// activity's content state is refreshed.
  func update(data: [String: Any]) async throws {
    let (attrs, state) = try unpack(data)
    let existing = Activity<CookingActivityAttributes>.activities

    if let activity = existing.first {
      await activity.update(ActivityContent(state: state, staleDate: nil))
    } else {
      _ = try Activity<CookingActivityAttributes>.request(
        attributes: attrs,
        content: ActivityContent(state: state, staleDate: nil),
        pushType: nil
      )
    }
  }

  /// End all cooking Live Activities immediately.
  func end() async {
    for activity in Activity<CookingActivityAttributes>.activities {
      await activity.end(nil, dismissalPolicy: .immediate)
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
      finishAction:       try str(d, "finishAction")
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
