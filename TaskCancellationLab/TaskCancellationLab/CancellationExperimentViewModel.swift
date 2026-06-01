import Combine
import Foundation
import SwiftUI

@MainActor
final class CancellationExperimentViewModel: ObservableObject {
    let totalSteps = 10

    @Published var selectedMode: ExperimentMode = .taskSleep
    @Published var status: ExperimentStatus = .idle
    @Published var currentStep = 0
    @Published var logs: [ExperimentLog] = []
    @Published var delaySeconds = 0.8

    private var task: Task<Void, Never>?

    var latestLog: ExperimentLog? {
        logs.last
    }

    func selectedModeDidChange() {
        reset()
    }

    func startTask() {
        task?.cancel()
        currentStep = 0
        logs.removeAll()
        status = .running

        append("Task started: \(selectedMode.rawValue)", kind: .user)
        append("Cancellation is a request, not a force-stop command.", kind: .task)

        let delay = delaySeconds
        let steps = totalSteps

        switch selectedMode {
        case .taskSleep:
            task = Task {
                await runTaskSleep(steps: steps, delay: delay)
            }
        case .threadSleep:
            task = Task.detached {
                await Self.runThreadSleep(
                    steps: steps,
                    delay: delay,
                    updateStep: { [weak self] step in
                        self?.currentStep = step
                    },
                    log: { [weak self] message, kind in
                        self?.append(message, kind: kind)
                    },
                    finish: { [weak self] newStatus, message in
                        self?.finish(newStatus, message)
                    }
                )
            }
        }
    }

    func cancelTask() {
        append("User requested cancellation.", kind: .user)
        task?.cancel()
    }

    func reset() {
        task?.cancel()
        task = nil
        status = .idle
        currentStep = 0
        logs.removeAll()
    }

    func stepColor(for step: Int) -> Color {
        if step > currentStep {
            return Color.secondary.opacity(0.18)
        }

        switch status {
        case .cancelled where step == currentStep:
            return .red
        case .completed:
            return .green
        default:
            return selectedMode.progressColor
        }
    }

    private func runTaskSleep(steps: Int, delay: Double) async {
        do {
            for step in 1...steps {
                append("Task.sleep is waiting before cell \(step).", kind: .task)
                try await Task.sleep(for: .seconds(delay))
                currentStep = step
                append("Task.sleep filled cell \(step).", kind: .task)
            }

            finish(.completed, "Task.sleep completed all cells.")
        } catch is CancellationError {
            append("Task.sleep threw CancellationError at a suspension point.", kind: .cancellation)
            finish(.cancelled, "Task.sleep stopped before filling the remaining cells.")
        } catch {
            finish(.cancelled, "Task.sleep stopped with error: \(error.localizedDescription)")
        }
    }

    nonisolated private static func runThreadSleep(
        steps: Int,
        delay: Double,
        updateStep: @MainActor @escaping (Int) -> Void,
        log: @MainActor @escaping (String, ExperimentLog.Kind) -> Void,
        finish: @MainActor @escaping (ExperimentStatus, String) -> Void
    ) async {
        await log("Thread.sleep starts blocking work.", .task)

        for step in 1...steps {
            blockingSleep(for: delay)
            await updateStep(step)
            await log("Thread.sleep filled cell \(step). Task.isCancelled is \(Task.isCancelled).", .task)
        }

        if Task.isCancelled {
            await log("Cancellation was requested, but Thread.sleep did not stop the loop early.", .cancellation)
            await finish(.cancelled, "Thread.sleep reached the end before cancellation had any practical effect.")
        } else {
            await finish(.completed, "Thread.sleep completed all cells.")
        }
    }

    nonisolated private static func blockingSleep(for delay: Double) {
        Thread.sleep(forTimeInterval: delay)
    }

    private func finish(_ newStatus: ExperimentStatus, _ message: String) {
        status = newStatus
        append(message, kind: .result)
        task = nil
    }

    private func append(_ message: String, kind: ExperimentLog.Kind) {
        logs.append(ExperimentLog(message: message, kind: kind))
    }
}
