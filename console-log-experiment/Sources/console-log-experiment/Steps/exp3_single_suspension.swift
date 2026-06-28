// exp3_SingleSuspension.swift
/*
 [Experiment 3: Single Suspension Point]
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
-> Console: [Task#00] Start: Main Thread
-> Is the task created with async/await?
-> Yes
-> [Task#00] async/await Task Created
-> [Task#00] Enter Async Function
-> Encounter await?
-> Yes -> [Task#00] Encounter await
-> [Task#00] Suspending Task
-> Suspend Task
-> Yield control to runtime
-> Execute Other Work
-> Perform Other Work
-> [Task#01] Other Tasks Running
-> Async Operation Completed -> [Task#00] Async Operation Completed
-> Resume Task
-> [Task#00] Task Resumed
-> [Task#00] Continue After await
-> More await Points?
-> No
-> Final Completion
-> [Task#00] End: Return to Main Thread
 */

import Foundation

// Note:
// This async function contains exactly one suspension point (Task.sleep),
// which causes the function to suspend and later resume from the same continuation point.
func asyncFunctionWithSingleSuspension() async {

    // Flow Chart: Enter Async Function
    print("[Task#00] Enter Async Function")

    // Flow Chart: Encounter await? -> Yes
    print("[Task#00] Encounter await")

    // Flow Chart: Console: Suspending Task
    print("[Task#00] Suspending Task")

    // Flow Chart: Suspended Task (Actual suspension point) -> Yield control to runtime
    try? await Task.sleep(for: .seconds(1))

    // Flow Chart: Async Operation Completed
    print("[Task#00] Async Operation Completed")

    // Flow Chart: Resume Task
    print("[Task#00] Task Resumed")

    // Flow Chart: Continue execution after await
    print("[Task#00] Continue After await")

    print("[Task#00] More await Points? -> No")
}

func runSingleSuspensionPath() {

    // Flow Chart: Start: Main Thread
    print("[Task#00] Start: Main Thread")

    Task {
        // Flow Chart: async/await Task Created
        print("[Task#00] async/await Task Created")

        await asyncFunctionWithSingleSuspension()

        // Flow Chart: Final Completion
        print("[Task#00] End: Return to Main Thread")
    }

    // Flow Chart: Execute Other Work -> Perform Other Work
    // Output order may vary due to Swift Concurrency scheduling.
    for index in 1...3 {
    Task {
        print("[Task#0\(index)] Other Tasks Running")
    }
  }
}