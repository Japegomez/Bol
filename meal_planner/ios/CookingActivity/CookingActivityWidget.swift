import ActivityKit
import SwiftUI
import WidgetKit

// ─────────────────────────────────────────────────────────────────────────────
// CookingActivityWidget
//
// Live Activity / Dynamic Island widget for an in-progress cooking session.
//
// Setup required (one-time in Xcode):
//  1. File > New > Target > Widget Extension (name: "CookingActivity")
//     – Uncheck "Include Configuration App Intent"
//  2. Add this file and CookingActivityAttributes.swift to the new target
//  3. Enable App Groups capability in BOTH Runner and CookingActivity targets:
//       group.com.japegomez.mealPlanner.cooking
//  4. Add NSSupportsLiveActivities = YES to Runner/Info.plist
//  5. The live_activities Flutter package initialises via AppGroupId in Dart
// ─────────────────────────────────────────────────────────────────────────────

@main
struct CookingActivityBundle: WidgetBundle {
    var body: some Widget {
        CookingActivityWidget()
    }
}

struct CookingActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CookingActivityAttributes.self) { context in
            // ── Lock Screen / Banner view ─────────────────────────────────
            CookingLockScreenView(context: context)
                .activityBackgroundTint(Color(.systemBackground))
        } dynamicIsland: { context in
            DynamicIsland {
                // ── Expanded Dynamic Island ───────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.stepText, systemImage: "fork.knife")
                        .font(.caption)
                        .lineLimit(2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPaused {
                        Text("Pausada")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(
                            timerInterval: context.state.chronometerBase...Date.distantFuture,
                            countsDown: false
                        )
                        .font(.caption.monospacedDigit())
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.attributes.recipeTitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        Spacer()
                        Text("Paso \(context.state.stepIndex + 1) / \(context.state.totalSteps)")
                            .font(.caption2)
                    }
                }
            } compactLeading: {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.orange)
            } compactTrailing: {
                if context.state.isPaused {
                    Image(systemName: "pause.fill")
                        .foregroundStyle(.secondary)
                } else {
                    Text(
                        timerInterval: context.state.chronometerBase...Date.distantFuture,
                        countsDown: false
                    )
                    .font(.caption2.monospacedDigit())
                    .frame(minWidth: 40)
                }
            } minimal: {
                Image(systemName: context.state.isPaused ? "pause.fill" : "fork.knife")
                    .foregroundStyle(.orange)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lock Screen view
// ─────────────────────────────────────────────────────────────────────────────

struct CookingLockScreenView: View {
    let context: ActivityViewContext<CookingActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.orange)
                Text(context.attributes.recipeTitle)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if context.state.isPaused {
                    Text("Pausada")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.secondary)
                } else {
                    Text(
                        timerInterval: context.state.chronometerBase...Date.distantFuture,
                        countsDown: false
                    )
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.orange)
                }
            }

            Divider()

            // Current step
            VStack(alignment: .leading, spacing: 4) {
                Text("Paso \(context.state.stepIndex + 1) de \(context.state.totalSteps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.state.stepText)
                    .font(.body)
                    .lineLimit(3)
            }

            // Action buttons (iOS 17+ App Intents; fallback: deep link)
            HStack(spacing: 12) {
                Spacer()
                if #available(iOS 17.0, *) {
                    Button(intent: CookingPauseResumeIntent(isPaused: context.state.isPaused)) {
                        Label(
                            context.state.isPaused ? "Continuar" : "Pausar",
                            systemImage: context.state.isPaused ? "play.fill" : "pause.fill"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(context.state.isPaused ? .green : .orange)

                    Button(intent: CookingFinishIntent()) {
                        Label("Terminar", systemImage: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                } else {
                    // Fallback: open app via URL scheme
                    Link(destination: URL(string: "recetea://cooking/resume")!) {
                        Label(
                            context.state.isPaused ? "Continuar" : "Pausar",
                            systemImage: context.state.isPaused ? "play.fill" : "pause.fill"
                        )
                    }
                    Link(destination: URL(string: "recetea://cooking/finish")!) {
                        Label("Terminar", systemImage: "stop.fill")
                    }
                }
            }
        }
        .padding()
    }
}
