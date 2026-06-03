import Foundation

@available(macOS 10.15, *) 
func run(step: ExperimentStep) {
    switch step {
    case .step1:
        runSynchronousPath()

    case .step2:
        runAsyncNoAwaitPath()
    }
}

extension ExperimentStep {
    var description: String {
        switch self {
        case .step1:
            return "Step 1 - Synchronous Path Experiment"
        case .step2:
            return "Step 2 - Async Task Without Await"
        }
    }
}