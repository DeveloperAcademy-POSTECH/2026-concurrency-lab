import SwiftUI

enum ExperimentMode: String, CaseIterable, Identifiable {
    case taskSleep = "Task.sleep"
    case threadSleep = "Thread.sleep"

    var id: String { rawValue }

    var question: String {
        switch self {
        case .taskSleep:
            "What happens to the next cell after you press Cancel?"
        case .threadSleep:
            "Do the cells stop filling after you press Cancel?"
        }
    }

    var watchInstruction: String {
        switch self {
        case .taskSleep:
            "Cancel while `Task.sleep` is waiting. The next cell should stop before it fills."
        case .threadSleep:
            "Cancel while `Thread.sleep` is running. Cells may keep filling after cancellation is requested."
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
