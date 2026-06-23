import Foundation

func run(exp: ExperimentCase) {
    switch exp {
    case .exp1:
        runSynchronousPath()

    case .exp2:
        runAsyncNoAwaitPath()

    case .exp3:
        runSingleSuspensionPath()

    case .exp4:
        runMultipleSuspensionPath()
    }

}

extension ExperimentCase {
    var description: String {
        switch self {
        case .exp1:
            return "[Experiment 1] Synchronous Path"
        case .exp2:
            return "[Experiment 2] Async Task Without Await"
        case .exp3:
            return "[Experiment 3] Single Suspension Point Execution"
        case .exp4:
            return "[Experiment 4] Multiple Suspension Point Execution"
        }
    }
}