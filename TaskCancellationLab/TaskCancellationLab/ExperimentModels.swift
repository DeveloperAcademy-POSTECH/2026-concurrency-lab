import SwiftUI

enum ExperimentMode: String, CaseIterable, Identifiable {
    case taskSleep = "Task.sleep"
    case threadSleep = "Thread.sleep"

    var id: String { rawValue }

    var question: String {
        switch self {
        case .taskSleep:
            "Where does a task stop when it is cancelled during `Task.sleep`?"
        case .threadSleep:
            "Does a task stop immediately when it is cancelled during blocking `Thread.sleep`?"
        }
    }

    var takeaway: String {
        switch self {
        case .taskSleep:
            "`Task.sleep` is a cancellation-aware suspension point, so a cancelled task can exit with `CancellationError`."
        case .threadSleep:
            "`Thread.sleep` is not a Swift Concurrency suspension point, so it does not automatically handle task cancellation."
        }
    }

    var progressColor: Color {
        switch self {
        case .taskSleep:
            .blue
        case .threadSleep:
            .orange
        }
    }
}

enum ExperimentStatus: String {
    case idle = "Idle"
    case running = "Running"
    case cancelled = "Cancelled"
    case completed = "Completed"

    var iconName: String {
        switch self {
        case .idle:
            "circle"
        case .running:
            "clock"
        case .cancelled:
            "xmark.octagon"
        case .completed:
            "checkmark.circle"
        }
    }

    var color: Color {
        switch self {
        case .idle:
            .secondary
        case .running:
            .blue
        case .cancelled:
            .red
        case .completed:
            .green
        }
    }
}

struct ExperimentLog: Identifiable {
    let id = UUID()
    let message: String
    let kind: Kind

    enum Kind {
        case user
        case task
        case cancellation
        case result

        var iconName: String {
            switch self {
            case .user:
                "hand.tap"
            case .task:
                "gearshape"
            case .cancellation:
                "xmark.octagon"
            case .result:
                "checkmark.circle"
            }
        }

        var color: Color {
            switch self {
            case .user:
                .blue
            case .task:
                .purple
            case .cancellation:
                .red
            case .result:
                .green
            }
        }
    }
}
