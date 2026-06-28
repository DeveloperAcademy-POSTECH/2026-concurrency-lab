import Combine
import Foundation
import SwiftUI

@MainActor
final class CancellationExperimentViewModel: ObservableObject {
    // Keep the experiment intentionally small so the cancellation point is easy to observe.
    let totalSteps = 10

    @Published var selectedMode: ExperimentMode = .taskSleep
    @Published var status: ExperimentStatus = .idle
    @Published var currentStep = 0
    @Published var logs: [ExperimentLog] = []

    private var task: Task<Void, Never>?
    private let delaySeconds = 1.2

    // The UI highlights the most recent event while the full timeline remains scrollable.
    var latestLog: ExperimentLog? {
        logs.last
    }

    func selectedModeDidChange() {
        reset()
    }

    func startTask() {
        // Cancel any previous run before starting a new experiment.
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
            // This task stays on the cooperative Swift Concurrency path.
            // Task.sleep can suspend and throw CancellationError when the task is cancelled.
            task = Task {
                await runTaskSleep(steps: steps, delay: delay)
            }
        case .threadSleep:
            // Thread.sleep blocks a thread, so run it off the MainActor to keep the UI responsive.
            // The callbacks hop back to the MainActor before mutating published UI state.
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
        // cancel() records a cancellation request. It does not forcefully stop synchronous work.
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
        // Unfilled cells stay neutral so the filled cells show the observed progress clearly.
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
                append("Task.sleep is waiting before cell \(step). Task.isCancelled is \(Task.isCancelled).", kind: .task)
                // This is the cancellation-aware suspension point in the experiment.
                try await Task.sleep(for: .seconds(delay))
                currentStep = step
                append("Task.sleep filled cell \(step). Task.isCancelled is \(Task.isCancelled).", kind: .task)
            }

            finish(.completed, "Task.sleep completed all cells.")
        } catch is CancellationError {
            // When cancellation is requested during Task.sleep, Swift can resume here with CancellationError.
            append("Task.sleep threw CancellationError at a suspension point. Task.isCancelled is \(Task.isCancelled).", kind: .cancellation)
            finish(.cancelled, "Task.sleep stopped before filling the remaining cells.")
        } catch {
            finish(.cancelled, "Task.sleep stopped with error: \(error.localizedDescription)")
        }
    }

    // This function is nonisolated because it performs blocking work away from the MainActor.
    nonisolated private static func runThreadSleep(
        steps: Int,
        delay: Double,
        updateStep: @MainActor @escaping (Int) -> Void,
        log: @MainActor @escaping (String, ExperimentLog.Kind) -> Void,
        finish: @MainActor @escaping (ExperimentStatus, String) -> Void
    ) async {
        await log("Thread.sleep starts blocking work.", .task)

        for step in 1...steps {
            await log("Thread.sleep is blocking before cell \(step). Task.isCancelled is \(Task.isCancelled).", .task)
            blockingSleep(for: delay)
            // Even after cancellation, Thread.sleep does not throw or suspend cooperatively.
            // The task can observe Task.isCancelled only after the blocking call returns.
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
        // This is deliberately synchronous and blocking to contrast with Task.sleep.
        Thread.sleep(forTimeInterval: delay)
    }

    private func finish(_ newStatus: ExperimentStatus, _ message: String) {
        // Finish all runs through one path so status, logs, and task cleanup stay consistent.
        status = newStatus
        append(message, kind: .result)
        task = nil
    }

    private func append(_ message: String, kind: ExperimentLog.Kind) {
        // Each log entry is immutable, which makes the timeline stable for SwiftUI diffing.
        logs.append(ExperimentLog(message: message, kind: kind))
    }
}
