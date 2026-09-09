# Experiment 3: Single Suspension

An experiment that makes one `await` boundary visible so suspension, runtime handoff, and resumption can be observed through console output.

## Overview

### Purpose

Experiment 3 demonstrates a single suspension point in an async function.

The implementation and repository description show this experiment is intended to observe:

- where execution is suspended
- how control is yielded to the runtime
- how and when the task resumes execution
- how other work can interleave while the task is suspended

### Source Example

The single suspension point is implemented with `Task.sleep`:

```swift
func asyncFunctionWithSingleSuspension() async {
    print("[Task#00] Enter Async Function")
    print("[Task#00] Encounter await")
    print("[Task#00] Suspending Task")

    try? await Task.sleep(for: .seconds(1))

    print("[Task#00] Async Operation Completed")
    print("[Task#00] Task Resumed")
    print("[Task#00] Continue After await")
    print("[Task#00] More await Points? -> No")
}
```

The experiment runner also starts additional Tasks:

```swift
func runSingleSuspensionPath() {
    print("[Task#00] Start: Main Thread")

    Task {
        print("[Task#00] async/await Task Created")
        await asyncFunctionWithSingleSuspension()
        print("[Task#00] End: Return to Main Thread")
    }

    for index in 1...3 {
        Task {
            print("[Task#0\\(index)] Other Tasks Running")
        }
    }
}
```

### Execution Flow

1. The experiment starts on the main thread.
2. The primary async `Task` is created.
3. The task enters the async function.
4. The function reaches `await` and logs that suspension is about to happen.
5. `Task.sleep` becomes the suspension point.
6. While the primary task is suspended, other tasks can run.
7. After the async operation completes, the suspended task resumes.
8. The function continues after `await` and prints its completion logs.

### Task Behavior

This experiment makes the suspension and resumption cycle visible in console output.

The primary task yields control when it reaches `try? await Task.sleep(for: .seconds(1))`. After that async operation completes, execution resumes from the continuation point and proceeds with the remaining logs.

Additional tasks are created outside the primary task to show that other work can be scheduled while the suspended task is waiting.

### Suspension Point

The suspension point is:

```swift
try? await Task.sleep(for: .seconds(1))
```

This is the single `await` boundary in the experiment.

### Console Output Meaning

| Console Output | Meaning |
| --- | --- |
| `[Task#00] Start: Main Thread` | The experiment begins before the async task body runs. |
| `[Task#00] async/await Task Created` | The primary task has been created. |
| `[Task#00] Enter Async Function` | Control enters the async function. |
| `[Task#00] Encounter await` | The code reaches the suspension boundary. |
| `[Task#00] Suspending Task` | The task is about to suspend at `Task.sleep`. |
| `[Task#01] Other Tasks Running` ... `[Task#03] Other Tasks Running` | Other tasks may run while the primary task is suspended. |
| `[Task#00] Async Operation Completed` | The awaited operation has completed. |
| `[Task#00] Task Resumed` | The suspended task resumes. |
| `[Task#00] Continue After await` | Execution continues after the suspension point. |
| `[Task#00] More await Points? -> No` | The function has no further suspension points. |
| `[Task#00] End: Return to Main Thread` | The primary task prints its final completion log. |

### Flow Chart Mapping

| Flow Chart Step | Corresponding Output or Code |
| --- | --- |
| Start: Main Thread | `[Task#00] Start: Main Thread` |
| Is the task created with async/await? -> Yes | `Task { ... }` in `runSingleSuspensionPath()` |
| async/await Task Created | `[Task#00] async/await Task Created` |
| Enter Async Function | `[Task#00] Enter Async Function` |
| Encounter await? -> Yes | `[Task#00] Encounter await` |
| Suspending Task | `[Task#00] Suspending Task` |
| Suspend Task / Yield control to runtime | `try? await Task.sleep(for: .seconds(1))` |
| Execute Other Work / Perform Other Work | The additional `Task` blocks created in the loop |
| Other Tasks Running | `[Task#01] Other Tasks Running` through `[Task#03] Other Tasks Running` |
| Async Operation Completed | `[Task#00] Async Operation Completed` |
| Resume Task | `[Task#00] Task Resumed` |
| Continue After await | `[Task#00] Continue After await` |
| More await Points? -> No | `[Task#00] More await Points? -> No` |
| Final Completion | `[Task#00] End: Return to Main Thread` |

### Implementation Notes

The source code explicitly notes that output order may vary due to Swift Concurrency scheduling.

That note is especially important for the `Other Tasks Running` logs, because those tasks are intended to demonstrate interleaving during the suspension window rather than a strict fixed order.

## See Also

- <doc:ConsoleLogExperiment>
- <doc:Experiment4MultipleSuspension>
