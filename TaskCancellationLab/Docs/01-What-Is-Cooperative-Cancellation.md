# What Is Cooperative Cancellation?

In Swift Concurrency, cancellation does not forcefully stop a running task from the outside. More precisely, cancellation is a request sent to a task.

This means that calling `task.cancel()` does not always stop the task immediately. The code running inside the task needs to reach a point where it can respond to cancellation.

`TaskCancellationLab` is a small SwiftUI experiment app for observing this difference directly. This version keeps the scope focused by comparing two ways of sleeping: `Task.sleep` and `Thread.sleep`.

## Why talk about cancellation in Swift Concurrency?

One of the big ideas in Swift Concurrency is that asynchronous work is represented as `Task` values, and those tasks can run with structured relationships. A task is not just a container that runs code. It also carries execution-related state such as priority, actor isolation, child tasks, and cancellation.

Cancellation is an important part of a task's lifecycle. For example, you may want to stop an async operation when a screen disappears, when a user changes a search query, or when the result of an older request is no longer needed. In Swift Concurrency, cancellation is the signal used for that situation.

However, cancellation in Swift Concurrency is not forceful termination. The runtime does not stop a task at an arbitrary line of code. Instead, a task needs to notice the cancellation request and stop cooperatively. That makes cancellation a natural topic when learning Swift Concurrency.

> When, where, and how can a task cooperate with cancellation?

## Core question

When the same cancellation request is sent, why can `Task.sleep` stop while `Thread.sleep` may keep going?

## What is a suspension point?

A suspension point is a place inside an async function where a task can pause temporarily. In Swift code, a call marked with `await` is usually the easiest way to recognize one.

```swift
let value = await loadValue()
```

At this point, the task can suspend instead of continuing to hold onto the current thread. The Swift Concurrency runtime can then run other work and later resume the original task when the awaited operation is ready.

Suspension points matter for cancellation because cancellation-aware async APIs can check the task's cancellation state at these points. They may throw an error or stop the remaining work. `Task.sleep` provides this kind of suspension point, while `Thread.sleep` only blocks the current thread and is not a Swift Concurrency suspension point.

## `Task.sleep`

`Task.sleep` is an async API in Swift Concurrency. It creates a suspension point and can respond to cancellation.

If a task is cancelled while it is sleeping with `Task.sleep`, the sleep can throw `CancellationError`.

```swift
do {
    try await Task.sleep(for: .seconds(1))
} catch is CancellationError {
    // cancelled at a suspension point
}
```

The important point is that `Task.sleep` is not just a function that waits for time to pass. It is a suspension point where the Swift Concurrency runtime can work with the task's state.

## `Thread.sleep`

`Thread.sleep` blocks the current thread. It is not a Swift Concurrency suspension point, and it does not use `await`.

```swift
Thread.sleep(forTimeInterval: 1)
```

Even if the task is cancelled while this code is running, `Thread.sleep` itself does not throw `CancellationError`. The task may be marked as cancelled, but the blocking sleep does not automatically handle that state.

## What to observe in this experiment

The app has two tabs.

- `Task.sleep`
- `Thread.sleep`

Both tabs run a task that fills 10 cells in order. The difference appears when you press `Cancel` while the task is running.

In the `Task.sleep` tab, the remaining cells should stop filling after cancellation is requested.

In the `Thread.sleep` tab, the cells may keep filling even after cancellation is requested. This does not mean cancellation failed. It means the blocking sleep does not automatically cooperate with Swift Concurrency cancellation.

## Summary

The core idea of this project can be summarized in one sentence.

> Cancellation is a request, and async code needs a place to cooperate.

`Task.sleep` provides a place to cooperate. `Thread.sleep` does not.
