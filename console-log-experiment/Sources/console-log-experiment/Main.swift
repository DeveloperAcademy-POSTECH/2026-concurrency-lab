// Main.swift
// Main entry point of the executable

import Foundation

@available(macOS 10.15, *)
@main
struct Main {

    static func main() async {

        // Prints the title of the concurrency experiment lab
        print("=== SWIFT CONCURRENCY LAB ===")

        // Displays a CLI menu for selecting an experiment step
        print("""
        ===============================
        1 - Step 1: Synchronous Path
        2 - Step 2: Async No Await
        3 - Step 3: Single Suspension
        ===============================
        Select Step:
        """, terminator: " ")

        // Reads user input from the command line
        // Converts the input string into a valid ExperimentStep enum case
        guard let input = readLine(),
              let step = ExperimentStep(rawValue: input) else {
            print("Invalid input")
            return
        }

        // Prints which experiment step is currently being executed
        print("\nRunning: \(step.description)\n")

        // Executes the selected experiment step
        // This acts as a dispatcher that routes execution to the correct function
        run(step: step)

        // Keeps the program alive for 2 seconds to allow asynchronous tasks
        // (e.g., Task { }) to complete their console output before program exits
        try? await Task.sleep(nanoseconds: 2_000_000_000)
    }
}