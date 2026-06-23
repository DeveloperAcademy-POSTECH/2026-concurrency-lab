// case1_sync.swift

// [Experiment 1: Synchronous Path]
// Complete synchronous path without async/await

/* Flow Chart
Start: Main Thread
-> Console: [Start] Main Thread
-> Is the task created with async/await?
-> No
-> Execute task synchronously
-> Console: Execute Synchronously
-> Console: [End] Task Finished - Return to Main Thread
-> End: Return to Main Thread
*/

import Foundation

func runSynchronousPath() {

    print("[Task#00] Start: Main Thread")

    // Is the task created with async/await? -> No
    print("[Task#00] Execute Synchronously")

    print("[Task#00] Task Finished - Return to Main Thread")
}