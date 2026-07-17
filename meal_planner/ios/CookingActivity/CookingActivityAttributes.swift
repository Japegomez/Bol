import ActivityKit
import Foundation

@available(iOS 16.1, *)
public struct CookingActivityAttributes: ActivityAttributes {
    public typealias ContentState = CookingContentState

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
        /// Localized labels pushed from Flutter.
        public var pausedLabel: String
        public var stepLabel: String
        public var pauseAction: String
        public var resumeAction: String
        public var finishAction: String
        /// Whether the step text is expanded (iOS 17+ interactive toggle).
        public var isTextExpanded: Bool

        var chronometerBase: Date {
            let epochMs = startedAtMs + accumulatedPauseMs
            return Date(timeIntervalSince1970: Double(epochMs) / 1000.0)
        }
    }
}
