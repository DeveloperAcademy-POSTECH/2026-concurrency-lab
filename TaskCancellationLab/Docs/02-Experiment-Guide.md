# Experiment Guide

This guide explains how to observe the difference between `Task.sleep` and `Thread.sleep` cancellation behavior in the `TaskCancellationLab` SwiftUI app.

The goal of this experiment is not just to compare two sleep APIs. The goal is to see how task cancellation works in Swift Concurrency, and where async code can cooperate with cancellation.

## Concepts to know before the experiment

In Swift Concurrency, a `Task` is the unit of async execution. When you call `task.cancel()`, a cancellation request is recorded on the task, but the running code is not forcefully stopped immediately.

For a task to stop naturally, it needs a point where it can respond to cancellation. In this experiment, we look at that point through the idea of a suspension point.

A suspension point is a place where async work can pause temporarily and later continue. A call marked with `await` can often be such a point.

```swift
try await Task.sleep(for: .seconds(1))
```

In contrast, a synchronous function like `Thread.sleep` blocks the current thread and is not a Swift Concurrency suspension point.

In this SwiftUI app, the `Thread.sleep` experiment runs inside `Task.detached`. This keeps the blocking work away from the MainActor so the UI can stay responsive while the experiment is running. The observed cancellation behavior is still about `Thread.sleep`: cancellation can be requested, but the blocking call does not automatically stop at that point.

The comparison is not between `Task` and `Task.detached`. It is between a cancellation-aware suspension point (`Task.sleep`) and a synchronous blocking call (`Thread.sleep`).

The basic flow of the app is simple.

1. Select the `Task.sleep` or `Thread.sleep` tab.
2. Press `Start`.
3. Watch the 10 cells fill one by one.
4. Press `Cancel` while the task is running.
5. Check whether the remaining cells keep filling or stop.

## Experiment 1: `Task.sleep`

### Question

Where does a task stop when it is cancelled during `Task.sleep`?

### Observation points

`Task.sleep` is a cancellation-aware suspension point. If a task is cancelled while sleeping, `Task.sleep` can throw `CancellationError` and prevent the task from continuing to the remaining work. The important point is that the cancel button does not physically cut off the task. Instead, the async point created by `Task.sleep` cooperates with the cancellation request.

In this experiment, the app waits before filling each cell. The cell is filled only after `Task.sleep` returns successfully. If cancellation is requested while the task is sleeping, `Task.sleep` throws `CancellationError`, so the code that updates the current step is skipped. That is why the next cell may never be filled.

### Expected result

When you press `Start`, the 10 cells fill in order. If you press `Cancel` in the middle, the next cells should no longer fill.

In the log, you can expect to see a flow similar to this.

```text
Task.sleep is waiting before cell 3.
User requested cancellation.
Task.sleep threw CancellationError at a suspension point.
Task.sleep stopped before filling the remaining cells.
```

### Takeaway

`Task.sleep` is not just a function that waits for time to pass. It is a point where the Swift Concurrency runtime can suspend and resume the task. Cancellation can also be handled at this point.

## Experiment 2: `Thread.sleep`

### Question

Does a task stop immediately when it is cancelled during a blocking sleep such as `Thread.sleep`?

### Observation points

`Thread.sleep` is not an async suspension point. It only blocks the current thread and does not automatically handle Swift task cancellation.

The app runs this blocking work in a detached task so pressing `Cancel` remains possible from the SwiftUI interface. UI updates are sent back to the MainActor after each blocking sleep finishes.

### Expected result

When you press `Start`, the 10 cells fill in order. If you press `Cancel` in the middle, the remaining cells may continue to fill.

In the log, you can expect to see a flow similar to this.

```text
User requested cancellation.
Thread.sleep filled cell 4. Task.isCancelled is true.
Thread.sleep filled cell 5. Task.isCancelled is true.
Cancellation was requested, but Thread.sleep did not stop the loop early.
```

### Takeaway

While `Thread.sleep` is running, the task's cancelled state can become `true`. However, the blocking sleep does not throw that state or stop the loop for you.

In other words, the cancellation request reached the task, but the running code did not provide an async cooperation point where that request could be handled.

The loop intentionally does not stop when `Task.isCancelled` becomes `true`. This makes the experiment show that `Thread.sleep` itself does not stop the loop. A developer could choose to check `Task.isCancelled` and break manually, but that would be explicit cooperative cancellation logic written by the developer.

## How to compare the two experiments

First, run the `Task.sleep` tab and press cancel while it is running. Check whether the remaining cells stop.

Then run the `Thread.sleep` tab and press cancel at a similar time. Check whether the cells continue to fill after the cancellation request.

This difference is the starting point for understanding cooperative cancellation.

## Adjusting the delay

Increasing the `Delay` value makes the cancellation timing easier to observe. If the experiment finishes too quickly, try increasing it to `1.0s` or more.
