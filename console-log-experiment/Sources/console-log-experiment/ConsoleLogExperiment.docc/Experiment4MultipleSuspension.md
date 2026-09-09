# Experiment 4: Multiple Suspension

An experiment that shows repeated suspension and resumption across multiple `await` boundaries in the same async task.

## Overview

### Purpose

Experiment 4 demonstrates multiple suspension points in an async function.

The implementation is designed to show how a task repeatedly suspends and resumes when it encounters multiple `await` boundaries during execution.

### Source Example

The async function contains two suspension points:

```swift
func asyncFunctionWithMultipleAwait() async {
    print("[Task#00] Enter Async Function")

    print("[Task#00] Suspending Task")
    try? await Task.sleep(for: .seconds(1))
    print("[Task#00] Task Resumed")
    print("[Task#00] Continue After await")
    print("[Task#00] More await Points? -> Yes")

    print("[Task#00] Suspending Task")
    try? await Task.sleep(for: .seconds(1))
    print("[Task#00] Task Resumed")
    print("[Task#00] Continue After await")
    print("[Task#00] More await Points? -> No")
}
```

The runner schedules additional concurrent work:

```swift
func runMultipleSuspensionPath() {
    print("[Task#00] Start: Main Thread")

    for index in 1...6 {
        Task {
            try? await Task.sleep(for: .seconds(Double(index) * 0.3))
            print("[Task#0\\(index)] Other Tasks Running")
        }
    }

    Task {
        print("[Task#00] async/await Task Created")
        await asyncFunctionWithMultipleAwait()
        print("[Task#00] End: Task Finished - Return to Main Thread")
    }
}
```

### Execution Flow

1. The experiment starts on the main thread.
2. Additional tasks are scheduled to represent other work.
3. The primary async task is created.
4. The task enters the async function.
5. The first `await` causes suspension and later resumption.
6. The function continues and confirms that more suspension points remain.
7. The second `await` causes another suspension and later resumption.
8. After the second continuation, the function reaches its final completion message.

### Task Behavior

This experiment repeats the suspension and resumption cycle more than once.

Each `try? await Task.sleep(for: .seconds(1))` marks a point where the primary task yields control. While that task is suspended, other tasks that were scheduled by the runner may continue to log their progress.

The experiment is intended to make repeated async boundaries visible in the console trace.

### Suspension Points

The experiment has two suspension points:

```swift
try? await Task.sleep(for: .seconds(1))
try? await Task.sleep(for: .seconds(1))
```

### Console Output Meaning

| Console Output | Meaning |
| --- | --- |
| `[Task#00] Start: Main Thread` | The experiment begins before the async task body runs. |
| `[Task#00] async/await Task Created` | The primary task has been created. |
| `[Task#00] Enter Async Function` | Control enters the async function. |
| `[Task#00] Suspending Task` | The primary task is about to suspend at an `await` boundary. |
| `[Task#0x] Other Tasks Running` | Concurrent work runs while the primary task is suspended. |
| `[Task#00] Task Resumed` | The primary task resumes after the awaited operation completes. |
| `[Task#00] Continue After await` | Execution continues after the current suspension point. |
| `[Task#00] More await Points? -> Yes` | The first resumption is followed by another suspension point. |
| `[Task#00] More await Points? -> No` | The second resumption completes the final async boundary. |
| `[Task#00] End: Task Finished - Return to Main Thread` | The experiment prints its final completion message. |

### Flow Chart Mapping

| Flow Chart Step | Corresponding Output or Code |
| --- | --- |
| Start: Main Thread | `[Task#00] Start: Main Thread` |
| Is the task created with async/await? -> Yes | `Task { ... }` in `runMultipleSuspensionPath()` |
| async/await Task Created | `[Task#00] async/await Task Created` |
| Enter Async Function | `[Task#00] Enter Async Function` |
| Encounter await? -> Yes | The first `try? await Task.sleep(for: .seconds(1))` |
| Suspending Task | `[Task#00] Suspending Task` |
| Suspend Task / Yield control to runtime | Each `Task.sleep` call |
| Execute Other Work / Perform Other Work | The additional tasks created in the `for index in 1...6` loop |
| Other Tasks Running | `[Task#01] Other Tasks Running` through `[Task#06] Other Tasks Running` |
| Resume Task | `[Task#00] Task Resumed` |
| Continue After await | `[Task#00] Continue After await` |
| More await Points? -> Yes | `[Task#00] More await Points? -> Yes` after the first resumption |
| Repeat Suspension / Resume Cycle | The second `Task.sleep` and following resumption logs |
| More await Points? -> No | `[Task#00] More await Points? -> No` |
| Final Completion | `[Task#00] End: Task Finished - Return to Main Thread` |

### Implementation Notes

The source code notes that output order may vary due to Swift Concurrency scheduling.

That matters here because the experiment intentionally mixes a primary task with additional delayed tasks, so the relative order of some console lines is part of what the experiment is meant to expose.

## See Also

- <doc:ConsoleLogExperiment>
- <doc:Experiment3SingleSuspension>
