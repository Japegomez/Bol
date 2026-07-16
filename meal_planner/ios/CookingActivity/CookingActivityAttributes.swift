import ActivityKit
import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// CookingActivityAttributes
//
// Defines the static and dynamic data for the "Cooking Session" Live Activity.
// The Flutter side (live_activities package) pushes a flat dictionary through
// the shared App Group; these keys must match _kKey* constants in
// cooking_live_activity_service.dart.
// ─────────────────────────────────────────────────────────────────────────────

public struct CookingActivityAttributes: ActivityAttributes {
    public typealias ContentState = CookingContentState

    /// Static: set when the activity is created and never changes.
    public let recipeTitle: String

    public struct CookingContentState: Codable, Hashable {
        public var stepIndex: Int
        public var totalSteps: Int
        public var stepText: String
        public var isPaused: Bool
        /// Milliseconds since epoch at which cooking started.
        public var startedAtMs: Int
        /// Accumulated pause duration in milliseconds.
        public var accumulatedPauseMs: Int
        /// Milliseconds since epoch at which the session was paused, or nil.
        public var pausedAtMs: Int?

        /// The base date for a SwiftUI Text timer:
        ///   Date(ms: startedAtMs + accumulatedPauseMs)
        var chronometerBase: Date {
            let epochMs = startedAtMs + accumulatedPauseMs
            return Date(timeIntervalSince1970: Double(epochMs) / 1000.0)
        }
    }
}
