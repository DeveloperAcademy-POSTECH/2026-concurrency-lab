// exp2_async_no_await.swift

// [Experiment 2: Async Task Without Await]
// Verifies the execution flow when entering an async context (Task) 
// but lacking any 'await' suspension points inside the function.

/*
 Flow Chart
 Start: Main Thread
 -> Console: [Task#00] Start: Main Thread
 -> Is the task created with async/await?
 -> Yes
 -> [Task#00] async/await Task Created
 -> [Task#00] Enter Async Function
 -> Encounter await?
 -> No
 -> [Task#00] Execute task Synchronously
 -> Console: [Task#00] End: Return to Main Thread
 -> End: Return to Main Thread
*/

import Foundation

// Note: 
// This async function contains no suspension points (no 'await' inside body),
// so it executes sequentially without suspension.
func asyncFunctionWithoutAwait() async {

    // Flow Chart: Enter Async Function
    print("[Task#00] Enter Async Function")
    
    // Flow Chart: Encounter await? -> No -> Execute task Synchronously
    print("[Task#00] Execute task Synchronously")
}

/// Triggers and drives the case 2 experiment path.
func runAsyncNoAwaitPath() {
    print("[Task#00] Start: Main Thread")

    // Flow Chart: Is the task created with async/await? -> Yes
    // Note: Task is not executed immediately; it is scheduled by Swift Concurrency runtime.
    Task {
        // Flow Chart: async/await Task Created
        print("[Task#00] async/await Task Created")
        
        // Invoke the asynchronous function
        await asyncFunctionWithoutAwait()
        
        // Flow Chart: End: Return to Main / Final Completion log matching
        print("[Task#00] End: Return to Main Thread")
    }
}