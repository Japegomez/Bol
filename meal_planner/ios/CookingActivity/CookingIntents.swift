import ActivityKit
import AppIntents
import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// App Intents for Live Activity interactive buttons (iOS 17+)
//
// These intents write a pending action to the shared App Group UserDefaults,
// which the Flutter app reads on next resume via the cooking session provider.
// Additionally, they update or end the Live Activity immediately via ActivityKit.
// ─────────────────────────────────────────────────────────────────────────────

private let kAppGroupId = "group.com.japegomez.mealPlanner.cooking"
private let kPendingActionKey = "cooking_pending_action_v1"

@available(iOS 17.0, *)
struct CookingPauseResumeIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Pause or Resume Cooking"

    @Parameter(title: "Is Paused")
    var isPaused: Bool

    init() { isPaused = false }
    init(isPaused: Bool) { self.isPaused = isPaused }

    func perform() async throws -> some IntentResult {
        let action = isPaused ? "resume" : "pause"
        UserDefaults(suiteName: kAppGroupId)?.set(action, forKey: kPendingActionKey)

        let nowMs = Int(Date().timeIntervalSince1970 * 1000)
        let activities = Activity<CookingActivityAttributes>.activities
        for activity in activities {
            var state = activity.content.state
            if action == "pause" {
                guard !state.isPaused else { continue }
                state.isPaused = true
                state.pausedAtMs = nowMs
            } else {
                guard state.isPaused else { continue }
                if let pausedAt = state.pausedAtMs {
                    state.accumulatedPauseMs += max(0, nowMs - pausedAt)
                }
                state.isPaused = false
                state.pausedAtMs = nil
            }
            await activity.update(
                ActivityContent(state: state, staleDate: nil)
            )
        }

        return .result()
    }
}

@available(iOS 17.0, *)
struct CookingFinishIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Finish Cooking"

    func perform() async throws -> some IntentResult {
        UserDefaults(suiteName: kAppGroupId)?.set("finish", forKey: kPendingActionKey)

        let activities = Activity<CookingActivityAttributes>.activities
        for activity in activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }

        return .result()
    }
}
