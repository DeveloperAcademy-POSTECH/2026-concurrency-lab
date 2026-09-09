# console-log-experiment

An executable Swift Package that studies Swift Concurrency through small console log experiments focused on task creation, suspension, and resumption.

@Metadata {
    @TechnologyRoot
}

## Overview

`console-log-experiment` is a Swift Package Manager executable package for studying Swift Concurrency through console-log-based experiments.

This project focuses on observable execution flow rather than application features. The experiments are designed to help readers understand:

- how Tasks are created and executed
- when suspension occurs
- how execution resumes after `await`
- how asynchronous functions interact with execution flow
- how Swift schedules concurrent work

### Project Purpose

The purpose of this project is to build a deeper understanding of Swift Concurrency by observing how `async`/`await` behaves during Task execution.

Rather than focusing on application development, the project approaches concurrency from an experimental perspective. Each experiment isolates a specific execution scenario and analyzes it through console logs.

### Swift Concurrency Concepts

The project documentation and experiments focus on these concepts:

- `async` / `await`
- `Task`
- Suspension
- Resumption
- Structured Concurrency
- `MainActor`
- `async let`
- `Task Group`

### Current Package Structure

The current package is an executable target named `console-log-experiment` and contains the following implementation files:

```text
Package.swift
Sources/
└── console-log-experiment/
    ├── Main.swift
    ├── ExperimentRunner.swift
    ├── ExperimentStep.swift
    └── Steps/
        ├── exp1_sync.swift
        ├── exp2_async_no_await.swift
        ├── exp3_single_suspension.swift
        └── exp4_multiple_suspension.swift
```

`Main.swift` displays the experiment menu, reads CLI input, and keeps the process alive long enough for asynchronous Tasks to finish their console output.

`ExperimentRunner.swift` dispatches the selected experiment.

`ExperimentStep.swift` defines the `ExperimentCase` values used by the CLI menu.

### Experiment Layout

The experiments are organized as small, isolated console programs:

1. Experiment 1: Synchronous Path
2. Experiment 2: Async Task Without Await
3. Experiment 3: Single Suspension Point
4. Experiment 4: Multiple Suspension Points

Each experiment documents a different execution pattern so that the console output can be read as an execution trace.

### Experiment Summary

#### Experiment 1: Synchronous Path

Demonstrates a fully synchronous execution flow with no `async`/`await`. It serves as the baseline for comparison.

See <doc:Experiment1SynchronousPath>.

#### Experiment 2: Async Task Without Await

Enters an asynchronous `Task` context, but the async function body has no suspension point. This shows that an async function can still execute sequentially when no `await` is encountered.

See <doc:Experiment2AsyncNoAwait>.

#### Experiment 3: Single Suspension

Demonstrates one suspension point using `await` and shows suspension, runtime handoff, and resumption.

See <doc:Experiment3SingleSuspension>.

#### Experiment 4: Multiple Suspension

Demonstrates repeated suspension and resumption across multiple `await` boundaries.

See <doc:Experiment4MultipleSuspension>.

### Running the Experiments

Run the package from the project directory:

```bash
swift run
```

The executable displays a menu and accepts one of these inputs:

| Input | Experiment |
| --- | --- |
| `1` | Synchronous Path |
| `2` | Async Task Without Await |
| `3` | Single Suspension Point |
| `4` | Multiple Suspension Points |

### Console Logging Convention

This project uses a standardized tag system in the repository documentation:

| Tag | Description | Example |
| --- | --- | --- |
| `EXP` | Add new experiment code | `[EXP] add async function for suspension test` |
| `OBS` | Add observations about execution flow behavior | `[OBS] check thread hopping after resumption` |
| `LOG` | Add or modify console logging output | `[LOG] print thread id before and after await` |
| `DOC` | Update documentation, README, or learning notes | `[DOC] document state machine analysis in readme` |
| `RFT` | Improve or reorganize experiment structure | `[RFT] simplify task execution code blocks` |
| `CMP` | Compare different concurrency behaviors or execution models | `[CMP] test execution order of sync vs async` |
| `FIX` | Fix bugs, errors, or incorrect experiment behavior | `[FIX] resolve crash in async console printing` |

### Notes

This DocC catalog is based on the project README and checked against the current Swift source files. The documentation reorganizes the existing information for DocC navigation, but does not add new experiment behavior beyond what is described in the repository and implemented in code.

## Topics

### Experiments

- <doc:Experiment1SynchronousPath>
- <doc:Experiment2AsyncNoAwait>
- <doc:Experiment3SingleSuspension>
- <doc:Experiment4MultipleSuspension>
