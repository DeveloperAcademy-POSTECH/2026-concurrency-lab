# What I Learned

At first, it is easy to assume that calling `Task.cancel()` immediately stops a running task. But cancellation in Swift Concurrency is not forceful termination. It is a cancellation request.

This experiment compares two ways of sleeping: `Task.sleep` and `Thread.sleep`. They may look similar because both of them wait for a while, but they behave very differently from the perspective of cancellation.

## 1. Cancellation is connected to the Swift Concurrency execution model

Swift Concurrency runs async work in units called `Task`s. A task is not just a closure execution. It is an execution unit managed by the Swift Concurrency runtime. That is why concepts such as execution state, priority, parent-child relationships, and cancellation are attached to tasks.

From this perspective, cancellation is not just an extra feature. It is a way to manage a task's lifecycle. When a user no longer needs a result, when a screen transition makes work unnecessary, or when newer work replaces older work, cancellation sends the task a signal that says, "You may stop now."

The important lesson from this experiment is that this signal is not an automatic switch that stops code by itself. Cancellation in Swift Concurrency becomes meaningful when the running async code cooperates with it.

## 2. A suspension point is where a task can pause

A suspension point is a place inside an async function where a task can suspend. A call marked with `await` is usually the easiest example to think about.

```swift
let result = await fetchValue()
```

At this point, the task can pause without continuing to occupy the current thread. The Swift Concurrency runtime can run other work in the meantime, then resume the task when the awaited work is ready.

From the perspective of cancellation, this point is especially important. A cancellation-aware async API can check for a cancellation request at a suspension point and, if needed, throw `CancellationError` or avoid continuing the remaining work.

## 3. `Task.sleep` is a cancellation-aware suspension point

`Task.sleep` is an `async` API and is called with `await`.

```swift
try await Task.sleep(for: .seconds(1))
```

At this point, the task can suspend, and the Swift Concurrency runtime can observe the task's cancellation state. If a cancellation request arrives while the task is inside `Task.sleep`, `CancellationError` can be thrown and the remaining work may not continue.

## 4. `Thread.sleep` is a blocking call

`Thread.sleep` stops the current thread.

```swift
Thread.sleep(forTimeInterval: 1)
```

This call is not a Swift Concurrency suspension point. Even if a cancellation request arrives, `Thread.sleep` does not automatically throw `CancellationError`.

In the experiment, the `Thread.sleep` tab can continue filling cells even after cancellation. This does not mean cancellation was never recorded. It means the blocking code did not cooperate with cancellation.

## 5. Similar sleep APIs can have different cancellation behavior

The two APIs have similar names, so they may look like the same kind of waiting. In practice, they are very different.

- `Task.sleep`: async waiting that suspends a task
- `Thread.sleep`: synchronous waiting that blocks a thread

This difference matters in Swift Concurrency code.

## 6. Cancellation needs to be designed

Pressing a cancel button is not enough. We also need to look at where the running code can stop, which APIs are cancellation-aware, and whether the code is using blocking calls.

This app is a small experiment, but it points to one of the first questions to ask when thinking about cancellation in Swift Concurrency.

> Does this code have a point where it can cooperate with a cancellation request?
