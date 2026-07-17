import ActivityKit
import SwiftUI
import WidgetKit

@main
struct CookingActivityBundle: WidgetBundle {
    var body: some Widget {
        CookingActivityWidget()
    }
}

struct CookingActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CookingActivityAttributes.self) { context in
            CookingLockScreenView(context: context)
                .activityBackgroundTint(Color(.systemBackground))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Label(context.state.stepText, systemImage: "fork.knife")
                        .font(.caption)
                        .lineLimit(2)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isPaused {
                        Text(context.state.pausedLabel)
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
                        Text(context.state.stepLabel)
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

// MARK: – Lock screen view

struct CookingLockScreenView: View {
    let context: ActivityViewContext<CookingActivityAttributes>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // ── Header: recipe title + elapsed timer ─────────────────────────
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundStyle(.orange)
                Text(context.attributes.recipeTitle)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if context.state.isPaused {
                    Text(context.state.pausedLabel)
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

            // ── Step content (expandable on iOS 17+) ─────────────────────────
            VStack(alignment: .leading, spacing: 4) {
                Text(context.state.stepLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(context.state.stepText)
                    .font(.body)
                    .lineLimit(context.state.isTextExpanded ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)

                if #available(iOS 17.0, *) {
                    Button(intent: CookingToggleTextIntent()) {
                        Image(systemName: context.state.isTextExpanded
                              ? "chevron.up.circle" : "chevron.down.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }

            // ── Action buttons ────────────────────────────────────────────────
            if #available(iOS 17.0, *) {
                HStack(spacing: 6) {
                    // Previous step
                    Button(intent: CookingPreviousStepIntent()) {
                        Image(systemName: "backward.step.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .disabled(context.state.stepIndex == 0)

                    Spacer()

                    // Pause / Resume
                    Button(intent: CookingPauseResumeIntent(isPaused: context.state.isPaused)) {
                        Label(
                            context.state.isPaused
                                ? context.state.resumeAction
                                : context.state.pauseAction,
                            systemImage: context.state.isPaused ? "play.fill" : "pause.fill"
                        )
                    }
                    .buttonStyle(.bordered)
                    .tint(context.state.isPaused ? .green : .orange)

                    // Finish
                    Button(intent: CookingFinishIntent()) {
                        Label(context.state.finishAction, systemImage: "stop.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Spacer()

                    // Next step
                    Button(intent: CookingNextStepIntent()) {
                        Image(systemName: "forward.step.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(.secondary)
                    .disabled(context.state.stepIndex >= context.state.totalSteps - 1)
                }
            } else {
                // iOS 16 fallback: deep-link buttons
                HStack(spacing: 12) {
                    Spacer()
                    Link(destination: URL(string: context.state.isPaused
                         ? "recetea://cooking/resume"
                         : "recetea://cooking/pause")!) {
                        Label(
                            context.state.isPaused
                                ? context.state.resumeAction
                                : context.state.pauseAction,
                            systemImage: context.state.isPaused ? "play.fill" : "pause.fill"
                        )
                    }
                    Link(destination: URL(string: "recetea://cooking/finish")!) {
                        Label(context.state.finishAction, systemImage: "stop.fill")
                    }
                }
            }
        }
        .padding()
    }
}
