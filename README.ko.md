# ConcurrencyImageGallery

## Big Idea
Swift Concurrency

## Essential Question
Swift Concurrency는 어떻게 동작하며, 왜 사용해야 할까?

## Challenge Response
TaskGroup, Actor, @MainActor와 같은 Swift Concurrency 개념을 사용해 이미지 갤러리 앱을 구현한다.

---

## Overview

이 저장소는 Swift Concurrency를 직접 구현하고 비교하면서 학습하기 위해 만든 SwiftUI 기반 학습 프로젝트입니다.

이 프로젝트의 목표는 단순히 `async/await`를 사용하는 것이 아니라, 다음을 이해하는 데 있습니다.

- 비동기 이미지 로딩이 실제 UI 코드에서 어떻게 동작하는가
- 순차 실행과 병렬 실행은 어떤 차이를 보이는가
- SwiftUI에서 Task 취소는 언제 발생하는가
- actor는 공유 상태를 어떻게 안전하게 보호하는가
- in-flight 요청 deduplication은 어떻게 구현할 수 있는가
- 동시성 코드의 테스트 가능성은 어떻게 확보할 수 있는가
- Swift Testing으로 이런 동작을 어떻게 검증할 수 있는가

이 저장소의 모든 실험은 하나의 앱 안에서 독립된 탭으로 구성되어 있으며, 같은 이미지 로딩 문제를 서로 다른 동시성 기법으로 비교할 수 있도록 설계되었습니다.

---

## Learning Goals

- `async/await`의 실행 흐름 이해하기
- 순차 실행과 병렬 실행의 차이 비교하기
- SwiftUI 뷰 생명주기를 통해 Task 취소 관찰하기
- actor 격리와 공유 상태 보호 이해하기
- in-flight 요청 deduplication 이해하기
- 테스트 가능한 동시성 코드 작성 연습하기
- Swift Testing으로 동시성 동작 검증하기

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
앱의 시작점입니다.

**Responsibilities:**
- 앱 실행
- 루트 Scene 제공
- 루트 탭 뷰 로드

### `TabView.swift`
앱의 루트 탭 컨테이너입니다.

**Responsibilities:**
- 학습용 탭 표시
- 각 동시성 개념을 독립된 화면으로 분리
- 서로 다른 실행 모델을 비교하는 진입점 역할 수행

### `PicsumImage.swift`
공통 이미지 메타데이터 모델입니다.

**Responsibilities:**
- `picsum.photos` API 응답 디코딩
- `download_url`을 `downloadURL`로 매핑
- 모든 탭에서 공통으로 사용하는 이미지 모델 제공

### `LoadedImage.swift`
다운로드가 완료된 이미지 상태를 나타내는 모델입니다.

**Responsibilities:**
- 이미지 메타데이터와 다운로드된 `Data`를 함께 저장
- SwiftUI 렌더링을 위한 식별 가능한 모델 제공

### `ImageService.swift`
공통 네트워크 레이어입니다.

**Responsibilities:**
- `picsum.photos`에서 이미지 목록 가져오기
- 이미지 URL로부터 실제 이미지 데이터 가져오기
- 의존성 주입과 테스트를 위한 추상화 지점 제공

---

## Learning Tabs

### Tab 1 — Sequential
**Files:**
`SequentialView.swift`
`SequentialViewModel.swift`

**Purpose:**
- `async/await`를 사용한 순차 이미지 로딩을 보여준다
- `await`가 포함된 `for` 루프가 여전히 순차적으로 실행된다는 점을 보여준다
- 이후 탭과 비교하기 위한 기준점 역할을 한다

**Concepts explored:**
- `async/await`
- `@MainActor`
- suspension point
- 진행률 표시
- 경과 시간 측정

### Tab 2 — Parallel
**Files:**
`ParallelView.swift`
`ParallelViewModel.swift`

**Purpose:**
- 구조적 동시성을 사용한 병렬 이미지 로딩을 보여준다
- 순차 실행 방식과 성능 및 동작 차이를 비교한다
- 여러 자식 Task가 동시에 실행될 수 있음을 보여준다

**Concepts explored:**
- `withThrowingTaskGroup`
- 구조적 동시성
- 동시 실행
- Task 조정

### Tab 3 — Grid + Cancel
**Files:**
`GridCancelView.swift`
`GridCancelViewModel.swift`

**Purpose:**
- 스크롤 중 발생하는 Task 취소 동작을 보여준다
- SwiftUI가 사라지는 뷰에 연결된 Task를 어떻게 자동 취소하는지 보여준다
- 셀 단위 이미지 로딩과 뷰 생명주기의 관계를 관찰한다

**Concepts explored:**
- `.task(id:)`
- Task 취소
- `Task.checkCancellation()`
- SwiftUI Task 생명주기

### Tab 4 — Actor Cache
**Files:**
`ActorCacheView.swift`
`ActorCacheViewModel.swift`
`ImageCache.swift`

**Purpose:**
- actor 기반 공유 상태 보호를 보여준다
- 같은 이미지 요청에 대해 중복 다운로드를 방지한다
- in-flight 요청을 재사용하는 방식을 보여준다

**Concepts explored:**
- `actor`
- actor 격리
- 공유 상태 보호
- in-flight 요청 deduplication
- cache hit / miss 동작

---

## Testing

이 프로젝트는 Swift Concurrency를 학습하는 것뿐 아니라, 동시성 코드를 어떻게 테스트할 수 있는지도 함께 탐구합니다.

테스트 코드는 아래 위치에 있습니다.

```text
ConcurrencyImageGalleryTests/
└── ConcurrencyImageGalleryTests.swift
```

### Test Responsibilities
- Sequential 로딩 성공 동작 검증
- Sequential 로딩 실패 동작 검증
- actor cache reset 동작 검증
- in-flight 요청 deduplication 검증

### Testing Focus
이 프로젝트는 테스트를 구현 이후의 별도 작업으로 보지 않습니다. 테스트는 학습 과정의 일부로 사용되며, 다음을 검증하는 데 목적이 있습니다.

- 상태 변화가 기대한 대로 발생하는가
- 의존성 주입이 테스트 가능성을 높이는가
- 실제 네트워크 없이 동시성 로직을 분리해 검증할 수 있는가
- actor 동작을 테스트로 관찰할 수 있는가

---

## Running the App

Xcode에서 프로젝트를 열고 iOS 시뮬레이터에서 실행합니다.

앱은 다음 탭으로 구성됩니다.

```text
Sequential
Parallel
Grid + Cancel
Actor Cache
```

각 탭은 같은 이미지 로딩 문제를 서로 다른 동시성 방식으로 구현한 예제를 보여줍니다.

---

## Running the Tests

Xcode에서 아래 메뉴를 실행합니다.

```text
Product > Test
```

테스트 타깃은 Swift Testing을 사용하며, 다음과 같은 예제를 포함합니다.

- view model 상태 검증
- mock service 기반 실패 처리 검증
- actor cache 동작 검증
- 동시 요청 deduplication 검증

---

## Prerequisites

이 프로젝트를 실행하려면 다음이 필요합니다.

- Swift 6를 지원하는 Xcode
- iOS Simulator
- SwiftUI
- Swift Testing
- `picsum.photos`에서 이미지를 불러오기 위한 인터넷 연결

---

## Key Concepts

- `async / await`
- `Task`
- 구조적 동시성
- task group
- cancellation
- `@MainActor`
- `actor`
- dependency injection
- testability
- Swift Testing

---

## Documentation / Commit Convention

이 프로젝트는 학습 과정과 구현 의도를 더 명확하게 남기기 위해 아래와 같은 태그를 사용할 수 있습니다.

| Tag | Description | Example |
| --- | --- | --- |
| EXP | 새로운 동시성 실험 코드 추가 | `[EXP] implement parallel image loading tab` |
| OBS | 실행 동작 관찰 내용 추가 | `[OBS] compare sequential and parallel loading time` |
| LOG | 학습용 상태 표시 또는 로그 추가 | `[LOG] show loading progress in sequential tab` |
| DOC | README 또는 학습 기록 문서 수정 | `[DOC] document actor cache flow` |
| RFT | 코드 구조 리팩터링 | `[RFT] inject image service for testability` |
| CMP | 동시성 동작 비교 | `[CMP] compare sequential and task group execution` |
| FIX | 버그 또는 잘못된 동작 수정 | `[FIX] handle cancellation state in grid cell` |
| TST | 테스트 추가 또는 개선 | `[TST] add cache deduplication test` |

---

## Purpose

이 프로젝트의 목적은 같은 문제를 여러 방식으로 구현하고 비교하면서 Swift Concurrency를 더 깊이 이해하는 데 있습니다.

단순히 이미지 갤러리 앱을 만드는 것보다, 이 저장소는 앱이라는 맥락 안에서 동시성을 학습하기 위한 실험 프로젝트에 가깝습니다.

각 탭을 독립된 기능 실험으로 구성함으로써 이 프로젝트는 다음을 목표로 합니다.

- 순차 실행과 병렬 실행의 차이를 시각적으로 이해하기
- suspension과 cancellation이 UI 동작에 어떤 영향을 주는지 관찰하기
- actor가 공유 상태를 어떻게 안전하게 관리하는지 이해하기
- 의존성 주입을 통해 동시성 코드를 테스트 가능하게 만들기
- 직접 구현과 검증을 통해 Swift Concurrency에 대한 직관을 기르기

이러한 구현 과정과 테스트 결과를 함께 문서화함으로써, 이 저장소는 Swift Concurrency와 Swift Testing을 학습하기 위한 기록이자 실용적인 참고 자료 역할을 합니다.
