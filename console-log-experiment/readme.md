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
TBD

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
| EXP (Experiment) | 새로운 실험 코드 추가 | `[EXP] add async function for suspension test` |
| OBS (Observe) | 실행 흐름 관찰 내용 추가 | `[OBS] check thread hopping after resumption` |
| LOG (Console Log) | Console Log 추가/수정 | `[LOG] print thread id before and after await` |
| DOC (Docs) | 문서, README, 학습 정리 | `[DOC] document state machine analysis in readme` |
| RFT (Refactor) | 실험 구조 개선 | `[RFT] simplify task execution code blocks` |
| CMP (Compare) | 동기/비동기 비교 | `[CMP] test execution order of sync vs async` |
| FIX (Fix) | 실험 오류 수정 | `[FIX] resolve crash in async console printing` |

---

# Purpose
TBD