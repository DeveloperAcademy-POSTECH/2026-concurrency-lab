# Experiment 1: Synchronous Path

The baseline experiment for the project, showing a fully synchronous execution path without `async`/`await`.

## Overview

### Purpose

Experiment 1 demonstrates a fully synchronous execution flow.

According to the repository documentation, this experiment:

- contains no `async` / `await`
- demonstrates a fully synchronous path
- serves as the baseline for comparison with later experiments

### Source Example

The experiment implementation is:

```swift
func runSynchronousPath() {
    print("[Task#00] Start: Main Thread")
    print("[Task#00] Execute Synchronously")
    print("[Task#00] Task Finished - Return to Main Thread")
}
```

### Execution Flow

1. Execution starts on the main thread.
2. The experiment does not create an async Task.
3. Work is executed synchronously in order.
4. The function prints the completion message and returns.

### Task Behavior

This experiment does not enter an asynchronous Task context.

Because there is no `await`, there is no suspension point and no resumption step to observe. The console output is a direct representation of the synchronous path.

### Suspension Point

There is no suspension point in this experiment.

### Console Output Meaning

| Console Output | Meaning |
| --- | --- |
| `[Task#00] Start: Main Thread` | The experiment begins on the main thread. |
| `[Task#00] Execute Synchronously` | The work proceeds immediately without asynchronous suspension. |
| `[Task#00] Task Finished - Return to Main Thread` | The synchronous path ends and returns. |

### Flow Chart Mapping

| Flow Chart Step | Corresponding Output |
| --- | --- |
| Start: Main Thread | `[Task#00] Start: Main Thread` |
| Is the task created with async/await? -> No | No async `Task` is created in `runSynchronousPath()` |
| Execute task synchronously | `[Task#00] Execute Synchronously` |
| End: Return to Main Thread | `[Task#00] Task Finished - Return to Main Thread` |

### Implementation Note

This experiment is the reference point for understanding how later experiments differ once a `Task` is created and `await` introduces suspension.

## See Also

- <doc:ConsoleLogExperiment>
- <doc:Experiment2AsyncNoAwait>
