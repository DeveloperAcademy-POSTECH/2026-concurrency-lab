# ConcurrencyImageGallery

[English](README.md)

## Big Idea

**Swift Concurrency**

---

## Essential Questions

1. `await`를 사용하는 반복문과 `TaskGroup`을 사용하는 실행 흐름은 어떻게 다를까?
2. SwiftUI View의 생명주기는 비동기 이미지 요청의 취소에 어떤 영향을 줄까?
3. actor를 사용하면 공유 캐시와 진행 중인 요청을 어떻게 안전하게 관리할 수 있을까?

---

## Challenge

같은 이미지 로딩 문제를 순차 실행, 병렬 실행, Task 취소, actor 캐시로 각각 구현하고 실행 흐름과 상태 변화를 비교한다.

---

## Challenge Statement

`async/await`, `TaskGroup`, SwiftUI의 `.task`, actor를 사용해 이미지 갤러리를 구현하고, 각 동시성 기법이 실행 시간, 취소, 공유 상태 관리에 미치는 영향을 실험과 테스트로 검증한다.

---

## Overview

ConcurrencyImageGallery는 하나의 이미지 로딩 문제를 서로 다른 Swift Concurrency 방식으로 구현한 SwiftUI 학습 프로젝트다.

앱은 다음 네 개의 탭으로 구성된다.

| Tab | 학습 주제 |
| --- | --- |
| Sequential | `await`가 포함된 반복문의 순차 실행 |
| Parallel | `withThrowingTaskGroup`을 이용한 구조적 동시성 |
| Grid + Cancel | SwiftUI View 생명주기와 Task 취소 |
| Actor Cache | actor 격리, 캐시, 진행 중인 요청 중복 제거 |

각 탭은 구현 예시를 보여주는 데서 끝나지 않고, 실행 결과와 테스트를 통해 동작을 비교할 수 있도록 구성했다.

---

## Learning Goals

- `await`가 자동으로 병렬 실행을 만들지 않는다는 점을 이해한다.
- 서로 독립적인 작업을 `TaskGroup`으로 구조화하는 방법을 익힌다.
- SwiftUI의 `.task`와 View 생명주기에 따른 취소를 관찰한다.
- 취소와 일반 네트워크 오류를 구분한다.
- actor로 공유 상태를 격리하고 데이터 경쟁을 방지한다.
- 진행 중인 동일 요청을 재사용해 중복 다운로드를 방지한다.
- 의존성 주입과 Swift Testing으로 동시성 동작을 검증한다.

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

비동기 함수에 `await`를 사용하더라도 다음 코드처럼 반복문 안에서 한 번씩 기다리면 이미지 요청은 순차적으로 실행된다.

```swift
for item in list {
    let data = try await service.fetchImageData(from: item.downloadURL)
    images.append(LoadedImage(image: item, data: data))
}
```

이미지 요청들은 서로 의존하지 않으므로 동시에 실행할 수 있다. 이 실험에서는 순차 실행과 `TaskGroup`을 사용한 병렬 실행의 동작 차이를 비교했다.

## Approach

Parallel 탭에서는 각 이미지 요청을 `withThrowingTaskGroup`의 자식 Task로 추가했다.

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

순차 실행은 목록 순서대로 한 요청씩 완료한다. 병렬 실행은 여러 요청을 동시에 시작하고 먼저 완료된 결과부터 받는다.

## Experimental Conditions

외부 네트워크 속도와 URL 캐시의 영향을 제외하고 실행 구조만 비교하기 위해 지연 시간이 고정된 Mock Service를 사용했다.

| Item | Condition |
| --- | --- |
| Device | iPhone 17 Pro Simulator |
| OS | iOS 26.5 |
| Image requests | 10 |
| Delay per request | 100ms |
| Repetitions | 3 |
| External network | 사용하지 않음 |

`RequestProbe` actor로 현재 실행 중인 요청 수와 최대 동시 요청 수도 함께 기록했다.

## Results

| Execution | 3회 평균 시간 | 최대 동시 요청 수 | 전체 데이터 요청 수 |
| --- | ---: | ---: | ---: |
| Sequential | 1.03s | 1 | 10 |
| Parallel | 0.10s | 10 | 10 |

두 방식 모두 같은 수의 요청을 수행했지만, Sequential은 각 100ms 요청을 차례로 기다려 약 1초가 걸렸다. Parallel은 10개 요청이 겹쳐 실행되어 약 0.1초가 걸렸다.

이 결과는 통제된 지연 환경에서 실행 구조의 차이를 확인한 것이다. 실제 `picsum.photos` 요청 시간은 네트워크 상태, 서버 응답, URL 캐시의 영향을 받으므로 항상 같은 배수로 빨라진다는 의미는 아니다.

## Findings

- `await`는 비동기 함수의 완료를 기다리는 지점이며 자동으로 병렬 실행을 만들지 않는다.
- 서로 독립적인 요청은 `TaskGroup`의 자식 Task로 구성할 수 있다.
- `TaskGroup`은 모든 자식 Task가 끝날 때까지 부모 Task의 범위 안에서 관리된다.
- 병렬 실행 결과의 완료 순서는 입력 순서와 다를 수 있다.
- 실제 서비스에서는 요청 수가 많을 때 동시 실행 개수 제한도 함께 고려해야 한다.

---

# Experiment 2: View Lifecycle and Task Cancellation

## Problem

이미지 그리드에서 화면 밖으로 사라진 셀의 요청이 계속 실행되면 더 이상 필요하지 않은 네트워크 작업과 상태 변경이 발생할 수 있다.

또한 모든 오류를 취소로 처리하면 실제 네트워크 장애와 사용자가 더 이상 필요로 하지 않는 작업의 취소를 구분할 수 없다.

## Approach

각 셀은 이미지 ID와 연결된 `.task(id:)`에서 이미지를 요청한다.

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

SwiftUI가 셀과 연결된 Task를 취소할 수 있도록 별도의 비구조적 Task를 만들지 않았다. 취소는 `CancellationError`와 `URLError.cancelled`로 분리하고, 그 외 오류는 실패 상태로 표시한다.

## Results

| Situation | UI state |
| --- | --- |
| 셀이 유지되고 요청이 완료됨 | 이미지 표시 |
| 셀 Task가 취소됨 | 취소 아이콘 표시 |
| 취소가 아닌 요청 오류 발생 | 오류 아이콘과 접근성 오류 설명 표시 |

## Findings

- SwiftUI의 `.task`는 View의 생명주기와 연결된다.
- 취소는 협력적으로 동작하므로 suspension point와 `Task.checkCancellation()`에서 확인된다.
- 취소와 일반 오류를 분리해야 실제 실패를 취소로 오해하지 않는다.
- View와 연결된 작업 안에서 다시 비구조적 Task를 만들면 SwiftUI의 자동 취소 흐름에서 벗어날 수 있다.

---

# Experiment 3: Actor Cache and In-flight Deduplication

## Problem

여러 Task가 같은 이미지 URL을 동시에 요청할 때 각각 다운로드를 시작하면 네트워크 요청과 메모리 사용이 중복된다.

단순한 메모리 캐시는 첫 번째 다운로드가 끝난 뒤에는 재사용할 수 있지만, 다운로드가 아직 진행 중인 시점에 들어온 중복 요청은 막지 못한다.

## Approach

`ImageCache` actor가 완료된 데이터와 진행 중인 Task를 각각 관리한다.

```swift
actor ImageCache {
    private var storage: [URL: Data] = [:]
    private var inFlight: [URL: Task<Data, Error>] = [:]
}
```

요청 처리 순서는 다음과 같다.

```text
image(for:)
├── storage에 데이터가 있음 → cache hit
├── inFlight에 Task가 있음 → 기존 Task.value 재사용
└── 둘 다 없음 → 새 Task 생성 후 inFlight에 저장
```

actor 격리를 통해 `storage`, `inFlight`, 통계 값에 대한 접근을 직렬화한다.

## Results

Swift Testing에서 같은 URL에 대한 완료 후 재요청과 동시 요청을 각각 검증했다.

| Scenario | Hit | Miss | Deduplicated | 실제 데이터 요청 |
| --- | ---: | ---: | ---: | ---: |
| 같은 URL을 순서대로 2회 요청 | 1 | 1 | 0 | 1 |
| 같은 URL을 동시에 3회 요청 | 0 | 1 | 2 | 1 |

동시 요청 3개 중 첫 번째 요청만 다운로드 Task를 생성했고, 나머지 두 요청은 `inFlight`에 저장된 같은 Task의 결과를 기다렸다.

## Findings

- actor는 공유 상태에 대한 동시 접근을 안전하게 직렬화한다.
- actor를 사용하는 것만으로 중복 요청이 자동 제거되지는 않는다.
- 진행 중인 `Task`를 상태로 저장해야 완료 전 들어오는 중복 요청도 하나로 합칠 수 있다.
- `Task.value`를 여러 호출자가 기다려도 실제 데이터 요청은 한 번만 실행된다.

---

## Testing

테스트는 실제 네트워크를 사용하지 않고 `ImageServing`을 주입해 실행한다.

| Test | 검증 내용 |
| --- | --- |
| `sequentialViewModelLoadsImagesInOrder` | 순차 로딩 결과와 상태 변경 |
| `sequentialViewModelStoresErrorWhenListLoadingFails` | 목록 요청 실패 상태 |
| `parallelLoadingRunsIndependentRequestsConcurrently` | 순차·병렬 최대 동시 요청 수와 실행 시간 |
| `imageCacheResetClearsState` | 캐시와 통계 초기화 |
| `imageCacheDeduplicatesInFlightRequests` | 진행 중인 동일 요청의 중복 제거 |

이 테스트를 통해 UI나 외부 서버 상태에 의존하지 않고 동시성 로직의 실행 순서와 공유 상태 변화를 검증할 수 있다.

---

## Overall Findings

- 비동기 실행과 병렬 실행은 같은 개념이 아니다.
- 독립적인 작업은 `TaskGroup`을 통해 구조적으로 병렬화할 수 있다.
- SwiftUI의 `.task`는 View 생명주기와 연결되며 취소를 전달한다.
- 취소와 일반 오류는 서로 다른 상태로 처리해야 한다.
- actor는 공유 상태를 보호하지만 캐시와 중복 제거 정책은 직접 설계해야 한다.
- 고정 지연 Mock과 actor 기반 Probe를 사용하면 동시 실행 동작을 반복 가능한 테스트로 검증할 수 있다.

---

## Conclusion

이 프로젝트를 통해 `async/await`만 사용하는 순차 실행과 `TaskGroup`을 이용한 병렬 실행의 차이를 확인했다. 통제된 실험에서 10개의 독립적인 요청은 Sequential에서 최대 1개, Parallel에서 최대 10개가 동시에 실행되었고 실행 시간도 약 1.03초에서 0.10초로 줄었다.

또한 SwiftUI View의 생명주기와 연결된 Task 취소를 처리하고, 취소와 일반 오류를 구분했다. 공유 이미지 상태는 actor로 격리했으며, 진행 중인 Task를 재사용해 동일 URL에 대한 동시 요청 3개를 실제 데이터 요청 1개로 합칠 수 있음을 테스트로 검증했다.

이 결과는 Swift Concurrency의 문법 자체보다 작업의 관계, 생명주기, 공유 상태를 어떻게 구조화하느냐가 동시성 코드의 동작과 안정성을 결정한다는 점을 보여준다.

---

## Running the Project

저장소 루트에서 다음 프로젝트를 Xcode로 열고 iOS 시뮬레이터에서 실행한다.

```text
ConcurrencyImageGallery/ConcurrencyImageGallery.xcodeproj
```

테스트는 Xcode의 `Product > Test`에서 실행할 수 있다.
