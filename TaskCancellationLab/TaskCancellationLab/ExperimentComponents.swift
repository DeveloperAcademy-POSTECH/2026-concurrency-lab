import SwiftUI

struct ExperimentExplanationView: View {
    let mode: ExperimentMode
    let status: ExperimentStatus

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(status.rawValue, systemImage: status.iconName)
                .font(.headline)
                .foregroundStyle(status.color)

            VStack(alignment: .leading, spacing: 4) {
                Text("Question")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(mode.question)
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Watch")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(mode.watchInstruction)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .layoutPriority(1)
    }
}

struct ExperimentControlsView: View {
    let status: ExperimentStatus
    let start: () -> Void
    let cancel: () -> Void
    let reset: () -> Void

    var body: some View {
        HStack {
            Button {
                start()
            } label: {
                Label("Start", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(status == .running)

            Button {
                cancel()
            } label: {
                Label("Cancel", systemImage: "xmark")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(status != .running)

            Button {
                reset()
            } label: {
                Label("Reset", systemImage: "arrow.clockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}

struct ExperimentProgressView: View {
    let mode: ExperimentMode
    let status: ExperimentStatus
    let currentStep: Int
    let totalSteps: Int
    let latestLog: ExperimentLog?
    let stepColor: (Int) -> Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(mode.rawValue)
                    .font(.caption.weight(.semibold))

                Spacer()

                Text("\(currentStep) / \(totalSteps)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            StepGridView(
                currentStep: currentStep,
                totalSteps: totalSteps,
                stepColor: stepColor
            )

            if let latestLog {
                LatestEventView(log: latestLog)
            }
        }
    }
}

struct StepGridView: View {
    let currentStep: Int
    let totalSteps: Int
    let stepColor: (Int) -> Color

    var body: some View {
        // A fixed-size grid makes the cancellation result visible without reading the timeline first.
        HStack(spacing: 6) {
            ForEach(1...totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 4)
                    .fill(stepColor(step))
                    .overlay {
                        Text("\(step)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(step <= currentStep ? .white : .secondary)
                    }
                    .frame(height: 30)
            }
        }
    }
}

struct LatestEventView: View {
    let log: ExperimentLog

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: log.kind.iconName)
                .foregroundStyle(log.kind.color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text("Latest event")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(log.message)
                    .font(.caption)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(log.kind.color.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct ExperimentTimelineView: View {
    let logs: [ExperimentLog]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    if logs.isEmpty {
                        ContentUnavailableView(
                            "No Events Yet",
                            systemImage: "clock.badge.questionmark",
                            description: Text("Start an experiment and cancel it while it is running.")
                        )
                        .frame(maxWidth: .infinity, minHeight: 220)
                    } else {
                        ForEach(Array(logs.enumerated()), id: \.element.id) { index, log in
                            TimelineRowView(log: log, index: index + 1)
                                .id(log.id)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .onChange(of: logs.count) {
                guard let lastID = logs.last?.id else { return }

                // Keep the newest event in view while the experiment is running.
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(lastID, anchor: .bottom)
                }
            }
        }
    }
}

private struct TimelineRowView: View {
    let log: ExperimentLog
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(log.kind.color)
                        .frame(width: 24, height: 24)

                    Image(systemName: log.kind.iconName)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                }

                Rectangle()
                    .fill(.quaternary)
                    .frame(width: 2, height: 18)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Event \(index)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(log.message)
                    .font(.caption)
                    .textSelection(.enabled)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(log.kind.color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}
