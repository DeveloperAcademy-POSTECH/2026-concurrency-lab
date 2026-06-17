// exp2_async_no_await.swift

// [Experiment 2: Async No Await]
// Verifies the execution flow when entering an async context (Task) 
// but lacking any 'await' suspension points inside the function.

/*
 Flow Chart
 Start: Main Thread
 -> Console: [Start] Main Thread
 -> Is the task created with async/await?
 -> Yes
 -> async/await Task Created
 -> Enter Async Function
 -> Encounter await?
 -> No
 -> Execute Synchronously
 -> Console: [End] Task Finished - Return to Main Thread
 -> End: Return to Main Thread
*/

import Foundation

@available(macOS 10.15, *) 
// Note: 
// This async function contains no suspension points (no 'await' inside body),
// so it executes sequentially without suspension.
func asyncFunctionWithoutAwait() async {

    // Flow Chart: Enter Async Function
    print("Enter Async Function")
    
    // Flow Chart: Encounter await? -> No -> Execute task Synchronously
    print("Execute task Synchronously")
}

/// Triggers and drives the case 2 experiment path.
@available(macOS 10.15, *) 
func runAsyncNoAwaitPath() {
    print("[Start] Main Thread")

    // Flow Chart: Is the task created with async/await? -> Yes
    // Note: Task is not executed immediately; it is scheduled by Swift Concurrency runtime.
    Task {
        // Flow Chart: async/await Task Created
        print("async/await Task Created")
        
        // Invoke the asynchronous function
        await asyncFunctionWithoutAwait()
        
        // Flow Chart: End: Return to Main / Final Completion log matching
        print("[End] Task Finished - Return to Main Thread")
    }
}