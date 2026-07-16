import ActivityKit
import Foundation

public struct CookingActivityAttributes: ActivityAttributes {
    public typealias ContentState = CookingContentState

    public let recipeTitle: String

    public struct CookingContentState: Codable, Hashable {
        public var stepIndex: Int
        public var totalSteps: Int
        public var stepText: String
        public var isPaused: Bool
        public var startedAtMs: Int
        public var accumulatedPauseMs: Int
        public var pausedAtMs: Int?
        /// Localized labels pushed from Flutter.
        public var pausedLabel: String
        public var stepLabel: String
        public var pauseAction: String
        public var resumeAction: String
        public var finishAction: String

        var chronometerBase: Date {
            let epochMs = startedAtMs + accumulatedPauseMs
            return Date(timeIntervalSince1970: Double(epochMs) / 1000.0)
        }
    }
}
