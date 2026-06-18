# Swift Concurrency Console Log Experiment

## Big Idea
Swift Concurrency

## Essential Question
How can async/await be better understood in Swift?

## Challenge
Explore how async/await works by studying task management with Swift Concurrency.

## Challenge Statement
Create a Swift Concurrency console log experiment that demonstrates how async/await handles Task execution through suspension and resumption, documented in a repository.

---

# Overview

This repository contains console log experiments designed to explore how Swift Concurrency works internally through observable execution flow.

The goal of this project is not simply to use async/await, but to understand:

- how Tasks are created and executed
- when suspension occurs
- how execution resumes after await
- how asynchronous functions interact with the call stack
- how Swift schedules concurrent work

All experiments are implemented as small, isolated Swift console programs focused on analyzing execution order through logging.

---

# Learning Goals

- Understand the execution flow of async/await
- Observe Task suspension and resumption
- Compare synchronous and asynchronous execution
- Analyze concurrent Task behavior through console logs
- Explore Swift Concurrency concepts experimentally

---

# Project Structure
This project is implemented as a Swift Package Manager (SwiftPM) executable package.
All concurrency experiments are located under:
```
Sources/
└── console-log-experiment/
    ├── Main.swift
    ├── ExperimentCase.swift
    ├── ExperimentRunner.swift
    └── Steps/
        ├── exp1_sync.swift
        ├── exp2_async_no_await.swift
        ├── exp3_single_suspension.swift
        └── exp4_multiple_suspension.swift
```
### Core Files
#### Main.swift
The executable entry point of the project.

Responsibilities:
- Displays the experiment selection menu
- Receives user input from the command line
- Converts input into an ExperimentCase
- Dispatches execution to the selected experiment
- Keeps the process alive long enough for asynchronous Tasks to complete

#### ExperimentCase.swift
Defines all available experiment cases.

Responsibilities:
- Maps CLI input values (1, 2, 3, 4) to experiment cases
- Provides a type-safe experiment selection mechanism
- Documents the purpose of each experiment

#### ExperimentRunner.swift
Acts as the experiment dispatcher.

Responsibilities:
- Receives the selected ExperimentCase
- Routes execution to the corresponding experiment function
- Provides human-readable descriptions for each experiment

### Experiment Cases
#### Experiment 1 — Synchronous Path
File: exp1_sync.swift
Purpose:
- Demonstrates a fully synchronous execution flow
- Contains no async/await
- Serves as the baseline for comparison with later experiments

#### Experiment 2 — Async Task Without Await
File: exp2_async_no_await.swift
Purpose:
- Enters an asynchronous Task context
- Contains no suspension points
- Demonstrates that an async function can still execute sequentially when no await is encountered

#### Experiment 3 — Single Suspension Point
File:exp3_single_suspension.swift
Purpose:
- Demonstrates a single suspension point using await
- Observes Task suspension and later resumption
- Visualizes execution flow before and after suspension

#### Experiment 4 — Multiple Suspension Points
Purpose:
- Demonstrates multiple await suspension points
- Observes repeated suspension and resumption cycles
- Explores how Swift Concurrency manages execution across multiple asynchronous boundaries

### Running the Experiments
Open the project directory in a terminal and run:
```
swift run
```

The executable will display a menu:
```
===============================
Experiment 1: Synchronous Path
Experiment 2: Async No Await
Experiment 3: Single Suspension
Experiment 4: Multiple Suspension
===============================
Select Experiment case:
```

Enter one of the following values and press Enter:
| Input | Experiment Case |
|-------|-----------------|
| 1 | Synchronous Path |
| 2 | Async Task Without Await |
| 3 | Single Suspension Point |
| 4 | Multiple Suspension Points |

The selected experiment will execute and print its execution flow to the console

### Prerequisites
This project requires:
- Swift 5.5 or later
- Swift Package Manager (included with Swift)
- macOS 13 or later

Verify your Swift installation:
```
swift --version
```

---

# Key Concepts

- async / await
- Task
- Suspension
- Resumption
- Structured Concurrency
- MainActor
- async let
- Task Group

---

# Experiment Logging Convention

All experiments in this repository follow a standardized tag system to make code intent and learning focus clear.

| Tag | Description | Example |
|------|-------------|---------|
| EXP (Experiment) | Add new experiment code | `[EXP] add async function for suspension test` |
| OBS (Observe) | Add observations about execution flow behavior | `[OBS] check thread hopping after resumption` |
| LOG (Console Log) | Add or modify console logging output정 | `[LOG] print thread id before and after await` |
| DOC (Docs) | Update documentation, README, or learning notes | `[DOC] document state machine analysis in readme` |
| RFT (Refactor) | Improve or reorganize experiment structure | `[RFT] simplify task execution code blocks` |
| CMP (Compare) | Compare different concurrency behaviors or execution models | `[CMP] test execution order of sync vs async` |
| FIX (Fix) | Fix bugs, errors, or incorrect experiment behavior | `[FIX] resolve crash in async console printing` |

---

# Purpose
The purpose of this project is to build a deeper understanding of Swift Concurrency by observing how async/await behaves during Task execution.

Rather than focusing on application development, this repository approaches concurrency from an experimental perspective. Each experiment isolates a specific execution scenario and analyzes it through console logs to reveal what happens behind the scenes when asynchronous code runs.

Through a series of controlled experiments, this project aims to:

- Visualize the execution flow of synchronous and asynchronous code
- Identify where Task suspension occurs
- Observe how execution resumes after await
- Compare execution behavior with and without suspension points
- Understand how Swift schedules and manages concurrent work
- Develop an intuition for Swift Concurrency through direct observation

By documenting these findings, the repository serves as both a learning record and a practical reference for understanding the internal behavior of Swift’s async/await model.