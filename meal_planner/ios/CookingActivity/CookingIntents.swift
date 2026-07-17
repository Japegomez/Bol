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
private let kAllStepTextsKey = "cooking_all_step_texts"
private let kAllStepLabelsKey = "cooking_all_step_labels"

// MARK: – Pause / Resume

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
        for activity in Activity<CookingActivityAttributes>.activities {
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
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
        return .result()
    }
}

// MARK: – Finish

@available(iOS 17.0, *)
struct CookingFinishIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Finish Cooking"

    func perform() async throws -> some IntentResult {
        UserDefaults(suiteName: kAppGroupId)?.set("finish", forKey: kPendingActionKey)

        for activity in Activity<CookingActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
        return .result()
    }
}

// MARK: – Toggle step text expansion

@available(iOS 17.0, *)
struct CookingToggleTextIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle Step Text"

    func perform() async throws -> some IntentResult {
        for activity in Activity<CookingActivityAttributes>.activities {
            var state = activity.content.state
            state.isTextExpanded.toggle()
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
        return .result()
    }
}

// MARK: – Next step

@available(iOS 17.0, *)
struct CookingNextStepIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Next Step"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: kAppGroupId)
        let stepTexts  = defaults?.stringArray(forKey: kAllStepTextsKey) ?? []
        let stepLabels = defaults?.stringArray(forKey: kAllStepLabelsKey) ?? []

        for activity in Activity<CookingActivityAttributes>.activities {
            var state = activity.content.state
            let newIndex = state.stepIndex + 1
            guard newIndex < state.totalSteps else { continue }
            defaults?.set("step:\(newIndex)", forKey: kPendingActionKey)
            state.stepIndex = newIndex
            if newIndex < stepTexts.count  { state.stepText  = stepTexts[newIndex] }
            if newIndex < stepLabels.count { state.stepLabel = stepLabels[newIndex] }
            state.isTextExpanded = false
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
        return .result()
    }
}

// MARK: – Previous step

@available(iOS 17.0, *)
struct CookingPreviousStepIntent: AppIntent, LiveActivityIntent {
    static var title: LocalizedStringResource = "Previous Step"

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: kAppGroupId)
        let stepTexts  = defaults?.stringArray(forKey: kAllStepTextsKey) ?? []
        let stepLabels = defaults?.stringArray(forKey: kAllStepLabelsKey) ?? []

        for activity in Activity<CookingActivityAttributes>.activities {
            var state = activity.content.state
            let newIndex = state.stepIndex - 1
            guard newIndex >= 0 else { continue }
            // Write absolute target index so Flutter's goToStep handles all
            // intermediate step-completion bookkeeping correctly.
            defaults?.set("step:\(newIndex)", forKey: kPendingActionKey)
            state.stepIndex = newIndex
            if newIndex < stepTexts.count  { state.stepText  = stepTexts[newIndex] }
            if newIndex < stepLabels.count { state.stepLabel = stepLabels[newIndex] }
            state.isTextExpanded = false
            await activity.update(ActivityContent(state: state, staleDate: nil))
        }
        return .result()
    }
}
