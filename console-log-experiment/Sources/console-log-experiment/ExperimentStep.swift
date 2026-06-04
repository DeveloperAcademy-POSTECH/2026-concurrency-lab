// Enum used to manage experiment execution cases in a structured and type-safe way
// Each case maps a user input string (from CLI) to a specific concurrency experiment scenario

enum ExperimentCase: String {
    case exp1 = "1" // Case 1: Synchronous execution path experiment (verifies non-concurrent sequential execution flow)
    case exp2 = "2" // Case 2: Async task execution without suspension points (no await, executes sequentially within task context)
    case exp3 = "3" // Case 3: Single suspension point experiment (demonstrates async function suspension and resumption behavior using await)
    case exp4 = "4" // Case 4: Multiple suspension point experiment (demonstrates repeated task suspension and resumption cycles caused by multiple await points)
}