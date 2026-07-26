# ConcurrencyImageGallery

[한국어](README.ko.md)

## Big Idea

**Swift Concurrency**

---

## Essential Questions

1. How does a loop containing `await` differ from an execution flow built with `TaskGroup`?
2. How does the SwiftUI view lifecycle affect cancellation of asynchronous image requests?
3. How can an actor safely manage shared cache state and in-flight requests?

---

## Challenge

Implement the same image-loading problem using sequential execution, parallel execution, task cancellation, and an actor cache, then compare their execution flows and state changes.

---

## Challenge Statement

Build an image gallery with `async/await`, `TaskGroup`, SwiftUI `.task`, and actors, then use experiments and tests to verify how each technique affects execution time, cancellation, and shared-state management.

---

## Overview

ConcurrencyImageGallery is a SwiftUI learning project that implements the same image-loading problem using several Swift Concurrency techniques.

The app contains four tabs.

| Tab | Learning topic |
| --- | --- |
| Sequential | Sequential execution in a loop containing `await` |
| Parallel | Structured concurrency with `withThrowingTaskGroup` |
| Grid + Cancel | SwiftUI view lifecycle and task cancellation |
| Actor Cache | Actor isolation, caching, and in-flight request deduplication |

Each tab goes beyond demonstrating an implementation. Its behavior is compared through execution results and tests.

---

## Learning Goals

- Understand that `await` does not automatically create parallel execution.
- Learn how to structure independent work with `TaskGroup`.
- Observe cancellation caused by SwiftUI `.task` and the view lifecycle.
- Distinguish cancellation from general network errors.
- Isolate shared state with an actor and prevent data races.
- Reuse an in-flight request to avoid duplicate downloads.
- Verify concurrent behavior using dependency injection and Swift Testing.

---

## Tech Stack

| Item | Value |
| --- | --- |
| Platform | iOS |
| Language | Swift 5 language mode |
| UI | SwiftUI |
| State Management | Observation (`@Observable`) |
| Concurrency | Swift Concurrency |
| Testing | Swift Testing |
| Image Source | `picsum.photos` |

---

## Project Structure

```text
ConcurrencyImageGallery/
├── ConcurrencyImageGallery.xcodeproj/
├── ConcurrencyImageGallery/
│   ├── ConcurrencyImageGalleryApp.swift
│   ├── TabView.swift
│   ├── Models/
│   │   ├── LoadedImage.swift
│   │   └── PicsumImage.swift
│   ├── Service/
│   │   └── ImageService.swift
│   └── Features/
│       ├── Sequential/
│       ├── Parallel/
│       ├── GridCancel/
│       └── ActorCache/
├── ConcurrencyImageGalleryTests/
│   └── ConcurrencyImageGalleryTests.swift
├── README.md
└── README.ko.md
```

---

# Experiment 1: Sequential vs Parallel

## Problem

Even when an asynchronous function uses `await`, image requests execute sequentially if each iteration waits for completion before continuing.

```swift
for item in list {
    let data = try await service.fetchImageData(from: item.downloadURL)
    images.append(LoadedImage(image: item, data: data))
}
```

The image requests do not depend on one another, so they can execute concurrently. This experiment compares sequential execution with parallel execution using `TaskGroup`.

## Approach

The Parallel tab adds each image request as a child task of `withThrowingTaskGroup`.

```swift
try await withThrowingTaskGroup(of: LoadedImage.self) { group in
    for item in list {
        group.addTask {
            let data = try await service.fetchImageData(from: item.downloadURL)
            return LoadedImage(image: item, data: data)
        }
    }

    for try await loaded in group {
        images.append(loaded)
    }
}
```

Sequential execution completes one request at a time in list order. Parallel execution starts multiple requests and receives results in completion order.

## Experimental Conditions

A mock service with a fixed delay was used to isolate execution structure from external network conditions and URL caching.

| Item | Condition |
| --- | --- |
| Device | iPhone 17 Pro Simulator |
| OS | iOS 26.5 |
| Image requests | 10 |
| Delay per request | 100ms |
| Repetitions | 3 |
| External network | Not used |

A `RequestProbe` actor recorded the number of active requests and the maximum request concurrency.

## Results

| Execution | 3-run average | Maximum concurrent requests | Total data requests |
| --- | ---: | ---: | ---: |
| Sequential | 1.03s | 1 | 10 |
| Parallel | 0.10s | 10 | 10 |

Both implementations performed the same number of requests. Sequential execution waited for ten 100ms requests one after another and took approximately one second. Parallel execution overlapped all ten requests and took approximately 0.1 seconds.

These results compare execution structure under a controlled delay. Real requests to `picsum.photos` are affected by network conditions, server response time, and URL caching, so the result does not mean that parallel loading is always faster by the same factor.

## Findings

- `await` marks a point that waits for an asynchronous operation; it does not automatically create parallel execution.
- Independent requests can be structured as child tasks in a `TaskGroup`.
- A `TaskGroup` keeps its child tasks within the lifetime of the parent task.
- Parallel results may complete in a different order from their input order.
- A real service should also consider limiting concurrency when the request count grows.

---

# Experiment 2: View Lifecycle and Task Cancellation

## Problem

If requests for off-screen grid cells continue running, they can perform unnecessary network work and state updates.

Treating every error as cancellation also makes it impossible to distinguish a network failure from work that is no longer needed.

## Approach

Each cell loads its image in `.task(id:)`, tied to the image identifier.

```swift
.task(id: image.id) {
    do {
        try await Task.sleep(for: .milliseconds(200))
        try Task.checkCancellation()
        let bytes = try await service.fetchImageData(from: image.downloadURL)
        try Task.checkCancellation()
        data = bytes
    } catch is CancellationError {
        didCancel = true
    } catch let error as URLError where error.code == .cancelled {
        didCancel = true
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

No unstructured task is created inside the view task, allowing SwiftUI to propagate cancellation to the image request. `CancellationError` and `URLError.cancelled` are handled as cancellation, while other errors are displayed as failures.

## Results

| Situation | UI state |
| --- | --- |
| The cell remains visible and the request completes | Image |
| The cell task is cancelled | Cancellation icon |
| A non-cancellation request error occurs | Error icon with an accessible error description |

## Findings

- SwiftUI `.task` is tied to the view lifecycle.
- Cancellation is cooperative and is observed at suspension points and `Task.checkCancellation()`.
- Cancellation and general errors must be handled separately to avoid misclassifying real failures.
- Creating an unstructured task inside a view task can escape SwiftUI's automatic cancellation flow.

---

# Experiment 3: Actor Cache and In-flight Deduplication

## Problem

When multiple tasks request the same image URL concurrently, starting a download for every caller duplicates network work and memory use.

A basic memory cache can reuse data after the first download finishes, but it cannot prevent duplicate requests that arrive while that download is still running.

## Approach

The `ImageCache` actor stores completed data and in-flight tasks separately.

```swift
actor ImageCache {
    private var storage: [URL: Data] = [:]
    private var inFlight: [URL: Task<Data, Error>] = [:]
}
```

Requests follow this flow.

```text
image(for:)
├── data exists in storage → cache hit
├── task exists in inFlight → reuse existing Task.value
└── neither exists → create a new Task and store it in inFlight
```

Actor isolation serializes access to `storage`, `inFlight`, and the cache statistics.

## Results

Swift Testing verifies both a repeated request after completion and concurrent requests for the same URL.

| Scenario | Hit | Miss | Deduplicated | Actual data requests |
| --- | ---: | ---: | ---: | ---: |
| Request the same URL twice sequentially | 1 | 1 | 0 | 1 |
| Request the same URL three times concurrently | 0 | 1 | 2 | 1 |

Only the first of the three concurrent callers created a download task. The other two callers waited for the same task stored in `inFlight`.

## Findings

- An actor safely serializes concurrent access to shared state.
- Using an actor does not automatically deduplicate requests.
- Storing the in-flight `Task` is necessary to merge duplicate requests that arrive before completion.
- Multiple callers can await the same `Task.value` while the underlying data request runs only once.

---

## Testing

Tests inject an `ImageServing` implementation and do not depend on the live network.

| Test | Responsibility |
| --- | --- |
| `sequentialViewModelLoadsImagesInOrder` | Sequential results and state transitions |
| `sequentialViewModelStoresErrorWhenListLoadingFails` | List request failure state |
| `parallelLoadingRunsIndependentRequestsConcurrently` | Sequential and parallel concurrency and timing |
| `imageCacheResetClearsState` | Cache and statistics reset |
| `imageCacheDeduplicatesInFlightRequests` | In-flight request deduplication |

This makes it possible to verify execution order and shared-state changes without depending on UI rendering or an external server.

---

## Overall Findings

- Asynchronous execution and parallel execution are different concepts.
- Independent work can be parallelized structurally with `TaskGroup`.
- SwiftUI `.task` propagates cancellation according to the view lifecycle.
- Cancellation and general errors should be represented as different states.
- An actor protects shared state, but cache and deduplication policies still require explicit design.
- A fixed-delay mock and an actor-based probe make concurrent behavior reproducible in tests.

---

## Conclusion

This project demonstrates the difference between sequential execution using `async/await` and parallel execution using `TaskGroup`. In a controlled experiment, ten independent requests reached a maximum concurrency of one in Sequential and ten in Parallel, reducing the observed duration from approximately 1.03 seconds to 0.10 seconds.

It also handles task cancellation tied to the SwiftUI view lifecycle and distinguishes cancellation from general failures. Shared image state is isolated with an actor, and tests show that three concurrent requests for the same URL can be merged into one actual data request by reusing an in-flight task.

The results show that the behavior and reliability of concurrent code depend less on concurrency syntax alone and more on how task relationships, lifetimes, and shared state are structured.

---

## Running the Project

From the repository root, open the following project in Xcode and run it on an iOS simulator.

```text
ConcurrencyImageGallery/ConcurrencyImageGallery.xcodeproj
```

Run the tests with `Product > Test` in Xcode.
