// exp3_SingleSuspension.swift
/*
 [Experiment 3: Single Suspension]
 Demonstrates a single suspension point in an async function.

 This experiment is designed to observe how a single 'await' (suspension point)
 affects the execution flow of a Swift Concurrency Task, specifically showing:

 - Where execution is suspended
 - How control is yielded to the runtime
 - How and when the task resumes execution
 - How concurrent "other work" interleaves with the suspended task
 */

/* Flow Chart
 Start: Main Thread
 -> Console: [Start] Main Thread
 -> Is the task created with async/await?
 -> Yes
 -> async/await Task Created
 -> Enter Async Function
 -> Encounter await?
 -> Yes
 -> Suspend Task
 -> Yield control to runtime
 -> Console: Task Suspended
 -> Execute Other Work
 -> Perform Other Work
 -> Console: Other Tasks Running
 -> Async Operation Completed
 -> Resume Task
 -> Console: Task Resumed
 -> Continue After await
 -> More await Points?
 -> No
 -> Final Completion
 -> Console: [End] Task Finished - Return to Main Thread
 -> End: Return to Main Thread
 */

import Foundation

@available(macOS 13, *)


// Note:
// This async function contains exactly one suspension point (Task.sleep),
// which causes the function to suspend and later resume from the same continuation point.
func asyncFunctionWithSingleSuspension() async {

    // Flow Chart: Enter Async Function
    print("Enter Async Function")

    // Flow Chart: Encounter await? -> Yes
    print("Encounter await")

    // Flow Chart: Suspend Task -> Yield control to runtime
    print("Task Suspended")

    // Actual suspension point
    try? await Task.sleep(for: .seconds(1))

    // Flow Chart: Async Operation Completed
    print("Async Operation Completed")

    // Flow Chart: Resume Task
    print("Task Resumed")

    // Flow Chart: Continue execution after await
    print("Continue After await")
}

@available(macOS 13, *)
func runSingleSuspensionPath() {

    // Flow Chart: Start: Main Thread
    print("[Start] Main Thread")

    Task {

        // Flow Chart: async/await Task Created
        print("async/await Task Created")

        await asyncFunctionWithSingleSuspension()

        // Flow Chart: Final Completion
        print("[End] Task Finished - Return to Main Thread")
    }

    // Flow Chart: Execute Other Work -> Perform Other Work
    for _ in 1...3 {
        print("Other Tasks Running")
    }
}