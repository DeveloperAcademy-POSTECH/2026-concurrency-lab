// exp4_multiple_suspension.swift

// [case 4 Experiment Function]
// Demonstrates multiple suspension points in an async function.

// This experiment verifies how a Task repeatedly suspends and resumes
// when encountering multiple 'await' suspension points during execution.

/*
 Flow Chart
 Start: Main Thread
 -> Console: [Start] Main Thread
 -> Is the task created with async/await?
 -> Yes
 -> async/await Task Created -> Console: async/await Task Created
 -> Enter Async Function -> Console: Enter Async Function
 -> Encounter await?
 -> Yes -> Console: Encounter await
 -> Console: Suspending Task
 -> Suspend Task
 -> Yield control to runtime
 -> Console: Task Suspended
 -> Execute Other Work
 -> Perform Other Work
 -> Console: Other Tasks Running
 -> Async Operation Completed -> Console: Async Operation Completed
 -> Resume Task
 -> Console: Task Resumed
 -> Continue After await -> Console: Continue After await
 -> More await Points?
 -> Yes

 [Repeat Suspension / Resume Cycle]

-> Suspend Task
 -> Yield control to runtime
 -> Console: Task Suspended
 -> Execute Other Work
 -> Perform Other Work
 -> Console: Other Tasks Running
 -> Async Operation Completed -> Console: Async Operation Completed
 -> Resume Task
 -> Console: Task Resumed
 -> Continue After await -> Console: Continue After await
 -> More await Points?
 -> No

 -> Final Completion
 -> Console: [End] Task Finished - Return to Main Thread
 -> End: Return to Main Thread
*/

import Foundation

@available(macOS 13, *)

// Note:
// This async function contains multiple suspension points (Task.sleep),
// causing the Task to suspend and resume multiple times before completion.

func asyncFunctionWithMultipleAwait() async {

    // Flow Chart: Enter Async Function
    print("Enter Async Function")

    // ===== Suspension Point #1 =====
    // Flow Chart: Encounter await? -> Yes -> Suspend Task -> Yield control to runtime
    print("Suspending Task")

    // Actual suspension point
    try? await Task.sleep(for: .seconds(1))

    // Flow Chart: Async Operation Completed -> Resume Task
    print("Task Resumed")

    // Flow Chart: Continue After await
    print("Continue After await")

    // Flow Chart: More await Points? -> Yes
    print("More await Points? -> Yes")

    // ===== Suspension Point #2 =====

    // Flow Chart: Suspend Task -> Yield control to runtime
    print("Suspending Task")

    // Actual suspension point
    try? await Task.sleep(for: .seconds(1))

    // Flow Chart: Async Operation Completed -> Resume Task
    print("Task Resumed")

    // Flow Chart: Continue After await
    print("Continue After await")

    // Flow Chart: More await Points? -> No
    print("More await Points? -> No")
}

// Triggers and executes case 4 multiple suspension experiment flow.
@available(macOS 13, *)
func runMultipleSuspensionPath() {

    // Flow Chart: Main thread starts execution
    print("[Start] Main Thread")

    // Simulated concurrent work executed while the primary Task is suspended
    Task {
        for index in 1...8 {
            try? await Task.sleep(for: .seconds(3))

            print("Other Tasks Running (\(index))")
        }
    }

    Task {

        // Flow Chart: Async task is created and scheduled by runtime
        print("async/await Task Created")

        // Execute async function containing multiple suspension points
        await asyncFunctionWithMultipleAwait()

        // Flow Chart: Final completion of async task execution
        print("[End] Task Finished - Return to Main Thread")
    }
}