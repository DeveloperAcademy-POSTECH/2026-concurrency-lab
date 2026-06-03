// Enum used to manage experiment execution steps in a structured and type-safe way
// Each case maps a user input string (from CLI) to a specific concurrency experiment scenario

enum ExperimentStep: String {
    case step1 = "1" // Step 1: Synchronous execution path experiment
    case step2 = "2" // Step 2: Async task execution without suspension points (no await)
}