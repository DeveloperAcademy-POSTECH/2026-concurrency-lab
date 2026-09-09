# Experiment 2: Async Task Without Await

An experiment that creates an asynchronous `Task` while keeping the async function body free of suspension points.

## Overview

### Purpose

Experiment 2 enters an asynchronous `Task` context, but the async function body contains no suspension point.

According to the repository documentation, this experiment is intended to show that an async function can still execute sequentially when no `await` is encountered.

### Source Example

The experiment is driven by these functions:

```swift
func asyncFunctionWithoutAwait() async {
    print("[Task#00] Enter Async Function")
    print("[Task#00] Execute task Synchronously")
}

func runAsyncNoAwaitPath() {
    print("[Task#00] Start: Main Thread")

    Task {
        print("[Task#00] async/await Task Created")
        await asyncFunctionWithoutAwait()
        print("[Task#00] End: Return to Main Thread")
    }
}
```

### Execution Flow

1. The experiment starts on the main thread.
2. A Swift Concurrency `Task` is created.
3. The task enters the async function.
4. The async function body executes sequentially.
5. The task prints the final completion message.

### Task Behavior

This experiment does create an asynchronous `Task`.

However, the async function itself contains no internal `await`, so there is no suspension inside `asyncFunctionWithoutAwait()`. Once the function body begins, its logged steps execute in order.

The source comments also note that the `Task` is scheduled by the Swift Concurrency runtime.

### Suspension Point

There is no suspension point inside `asyncFunctionWithoutAwait()`.

### Console Output Meaning

| Console Output | Meaning |
| --- | --- |
| `[Task#00] Start: Main Thread` | The experiment begins before the async task body runs. |
| `[Task#00] async/await Task Created` | The asynchronous task context has been created. |
| `[Task#00] Enter Async Function` | Control enters the async function body. |
| `[Task#00] Execute task Synchronously` | The function continues without suspension. |
| `[Task#00] End: Return to Main Thread` | The experiment reaches its completion log. |

### Flow Chart Mapping

| Flow Chart Step | Corresponding Output or Code |
| --- | --- |
| Start: Main Thread | `[Task#00] Start: Main Thread` |
| Is the task created with async/await? -> Yes | `Task { ... }` in `runAsyncNoAwaitPath()` |
| async/await Task Created | `[Task#00] async/await Task Created` |
| Enter Async Function | `[Task#00] Enter Async Function` |
| Encounter await? -> No | There is no internal `await` inside `asyncFunctionWithoutAwait()` |
| Execute task Synchronously | `[Task#00] Execute task Synchronously` |
| End: Return to Main Thread | `[Task#00] End: Return to Main Thread` |

### Implementation Note

This experiment separates two ideas:

- entering an async context by creating a `Task`
- suspending execution by encountering `await`

The first happens here, but the second does not occur inside the experiment function body.

## See Also

- <doc:ConsoleLogExperiment>
- <doc:Experiment3SingleSuspension>
