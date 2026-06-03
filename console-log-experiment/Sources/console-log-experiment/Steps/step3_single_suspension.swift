// Step3_SingleSuspension.swift

import Foundation

@available(macOS 10.15, *)

/*
 [Step 3 Experiment Function]
 Demonstrates a single suspension point in an async function.

 This experiment is designed to observe how a single 'await' (suspension point)
 affects the execution flow of a Swift Concurrency Task, specifically showing:

 - Where execution is suspended
 - How control is yielded to the runtime
 - How and when the task resumes execution
 - How concurrent "other work" interleaves with the suspended task
*/

// Note:
// This async function contains exactly one suspension point (Task.sleep),
// which causes the function to suspend and later resume from the same continuation point.
func asyncFunctionWithAwait() async {

    // Flow Chart: Enter Async Function
    print("Enter Async Function")

    // Flow Chart: Encounter await? -> Yes -> Suspend Task -> Yield control to runtime
    print("Task Suspended")

    // Actual suspension point (Task yields execution here to the Swift runtime)
    try? await Task.sleep(nanoseconds: 1_000_000_000)

    // Flow Chart: Resume Task after suspension completes
    print("Task Resumed")

    // Flow Chart: Continue execution after await
    print("Continue After await")
}

/*
 Flow Chart
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
 -> Console : Other Tasks Running
 -> More await Points?
 -> No
 -> Final Completion
 -> Console: [End] Task Finished - Return to Main Thread
 -> End: Return to Main Thread
*/

// Triggers and executes Step 3 suspension experiment flow.
@available(macOS 10.15, *)
func runSuspensionPath() {

    // Flow Chart: Main thread starts execution
    print("[Start] Main Thread")

    Task {

        // Flow Chart: Async task is created and scheduled by runtime
        print("async/await Task Created")

        // Executes async function containing a single suspension point
        await asyncFunctionWithAwait()

        // Flow Chart: Final completion of async task execution
        print("[End] Task Finished - Return to Main Thread")
    }

    // Simulated concurrent execution while Task is suspended
    for _ in 1...3 {
        print("Other Tasks Running")
    }
}