// Step1_SyncPath.swift
// Step 1: Complete synchronous path without async/await

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

    print("[Start] Main Thread")

    // Enter the "No" path of "Is the task created with async/await?"
    print("Execute Synchronously")

    print("[End] Task Finished - Return to Main Thread")
}