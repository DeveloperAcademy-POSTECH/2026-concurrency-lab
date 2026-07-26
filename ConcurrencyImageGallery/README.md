# ConcurrencyImageGallery

[한국어](README.ko.md)

## Big Idea
Swift Concurrency

## Essential Question
How does Swift Concurrency work, and why should it be used?

## Challenge Response
Build an image gallery app using Swift Concurrency concepts such as TaskGroup, Actor, and @MainActor.

---

## Overview

This repository contains a SwiftUI-based learning project designed to explore how Swift Concurrency works through direct implementation and comparison.

The goal of this project is not simply to use `async/await`, but to understand:

- how asynchronous image loading behaves in real UI code
- how execution differs between sequential and parallel flows
- when task cancellation occurs in SwiftUI
- how actors isolate shared mutable state
- how in-flight request deduplication can be implemented
- how concurrency-heavy code can be tested using Swift Testing

All experiments in this repository are implemented as isolated tabs inside the same app so that the same image-loading problem can be compared across different concurrency techniques.

---

## Learning Goals

- Understand the execution flow of `async/await`
- Compare sequential and parallel execution behavior
- Observe task cancellation through SwiftUI view lifecycle
- Explore actor isolation and shared-state protection
- Understand in-flight request deduplication
- Practice writing testable concurrency code
- Validate concurrency behavior with Swift Testing

---

## Tech Stack

| Item | Value |
| --- | --- |
| Platform | iOS |
| Language | Swift 6 |
| UI | SwiftUI |
| State Management | `@Observable` |
| Concurrency | Swift Concurrency |
| Testing | Swift Testing |
| Image Source | `picsum.photos` |

---

## Project Structure

```text
ConcurrencyImageGallery/
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
│       │   ├── SequentialView.swift
│       │   └── SequentialViewModel.swift
│       ├── Parallel/
│       │   ├── ParallelView.swift
│       │   └── ParallelViewModel.swift
│       ├── GridCancel/
│       │   ├── GridCancelView.swift
│       │   └── GridCancelViewModel.swift
│       └── ActorCache/
│           ├── ActorCacheView.swift
│           ├── ActorCacheViewModel.swift
│           └── ImageCache.swift
├── ConcurrencyImageGalleryTests/
│   └── ConcurrencyImageGalleryTests.swift
└── Products/
```

---

## Core Files

### `ConcurrencyImageGalleryApp.swift`
The app entry point of the project.

**Responsibilities:**
- launches the app
- provides the root scene
- loads the root tab view

### `TabView.swift`
The root tab container of the app.

**Responsibilities:**
- displays the learning tabs
- separates each concurrency concept into its own screen
- acts as the entry point for comparing execution models

### `PicsumImage.swift`
Defines the shared image metadata model.

**Responsibilities:**
- decodes the `picsum.photos` API response
- maps `download_url` into `downloadURL`
- provides a shared model for all tabs

### `LoadedImage.swift`
Defines the loaded image state used in UI rendering.

**Responsibilities:**
- stores downloaded image data together with image metadata
- provides an identifiable model for SwiftUI rendering

### `ImageService.swift`
Acts as the shared networking layer.

**Responsibilities:**
- fetches image lists from `picsum.photos`
- fetches image data from image URLs
- provides an abstraction point for dependency injection and testing

---

## Learning Tabs

### Tab 1 — Sequential
**Files:**
`SequentialView.swift`
`SequentialViewModel.swift`

**Purpose:**
- demonstrates sequential image loading with `async/await`
- shows that a `for` loop containing `await` still runs sequentially
- serves as the baseline for comparison with later tabs

**Concepts explored:**
- `async/await`
- `@MainActor`
- suspension points
- progress tracking
- elapsed time measurement

### Tab 2 — Parallel
**Files:**
`ParallelView.swift`
`ParallelViewModel.swift`

**Purpose:**
- demonstrates parallel image loading using structured concurrency
- compares performance and behavior against the sequential approach
- shows how child tasks can run concurrently

**Concepts explored:**
- `withThrowingTaskGroup`
- structured concurrency
- concurrent execution
- task coordination

### Tab 3 — Grid + Cancel
**Files:**
`GridCancelView.swift`
`GridCancelViewModel.swift`

**Purpose:**
- demonstrates cancellation behavior during scrolling
- shows how SwiftUI automatically cancels tasks tied to disappearing views
- visualizes how per-cell image loading interacts with view lifecycle

**Concepts explored:**
- `.task(id:)`
- task cancellation
- `Task.checkCancellation()`
- SwiftUI task lifecycle

### Tab 4 — Actor Cache
**Files:**
`ActorCacheView.swift`
`ActorCacheViewModel.swift`
`ImageCache.swift`

**Purpose:**
- demonstrates actor-based shared-state protection
- prevents duplicate downloads for repeated image requests
- shows how in-flight requests can be reused

**Concepts explored:**
- `actor`
- actor isolation
- shared mutable state protection
- in-flight request deduplication
- cache hit / miss behavior

---

## Testing

This project also explores how Swift Concurrency code can be tested.

The repository includes Swift Testing-based test cases located under:

```text
ConcurrencyImageGalleryTests/
└── ConcurrencyImageGalleryTests.swift
```

### Test Responsibilities
- validate sequential loading success behavior
- validate sequential loading failure behavior
- validate actor cache reset behavior
- validate in-flight request deduplication

### Testing Focus
This project does not treat testing as a separate concern from implementation. Instead, testing is used as part of the learning process to verify:

- whether state updates occur as expected
- whether dependency injection improves testability
- whether concurrency-related logic can be isolated from real networking
- whether actor behavior can be observed through tests

---

## Running the App

1. Open the project in Xcode.
2. Select the `ConcurrencyImageGallery` scheme.
3. Build and run on an iOS simulator.
4. Explore each tab and compare behavior:
   - Sequential
   - Parallel
   - Grid + Cancel
   - Actor Cache

---

## Running the Tests

In Xcode:

1. Open the `ConcurrencyImageGallery` project
2. Select the test target or main scheme
3. Run tests with `Product > Test`

You can also run individual Swift Testing cases directly from the gutter in Xcode.

---

## Prerequisites

This project requires:

- Xcode with Swift 6 support
- iOS Simulator
- SwiftUI
- Swift Testing
- Internet connection for runtime image loading from `picsum.photos`

---

## Key Concepts

- `async / await`
- `Task`
- structured concurrency
- task groups
- cancellation
- `@MainActor`
- `actor`
- dependency injection
- testability
- Swift Testing
