// Main.swift
// Main entry point of the executable

import Foundation

@available(macOS 13, *)
@main
struct Main {

    static func main() async {

        // Prints the title of the concurrency experiment lab
        print("=== SWIFT CONCURRENCY LAB ===")

        // Displays a CLI menu for selecting an experiment case
        print("""
        ===============================
        Experiment 1: Synchronous Path
        Experiment 2: Async No Await
        Experiment 3: Single Suspension
        Experiment 4: Multiple Suspension
        ===============================
        Select Experiment case:
        """, terminator: " ")

        // Reads user input from the command line
        // Converts the input string into a valid ExperimentCase enum case
        guard let input = readLine(),
              let experimentCase = ExperimentCase(rawValue: input) else {
            print("Invalid input")
            return
        }

        // Prints which experiment case is currently being executed
        print("\nRunning: \(experimentCase.description)\n")

        // Executes the selected experiment case
        // This acts as a dispatcher that routes execution to the correct function
        run(exp: experimentCase)

        // Keeps the program alive for 4 seconds to allow asynchronous tasks
        // (e.g., Task { }) to complete their console output before program exits
        try? await Task.sleep(for: .seconds(1))
    }
}