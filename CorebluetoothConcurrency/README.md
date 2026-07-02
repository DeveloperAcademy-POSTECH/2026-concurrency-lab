# CoreBluetooth + Swift Concurrency

## Big Idea

**Swift Concurrency**

---

## Essential Questions

1. What are the advantages of transforming a Delegate-based CoreBluetooth API into Swift Concurrency's asynchronous event flow?

2. How does the threading model change when BLE Delegate callbacks are executed on a dedicated Serial Queue instead of the Main Queue?

---

## Challenge

Analyze the differences between a Delegate-based CoreBluetooth architecture and a Swift Concurrency-based architecture in terms of readability, maintainability, stability, and threading behavior.

---

## Challenge Statement

Design and implement an event-driven CoreBluetooth architecture using `AsyncStream` and a dedicated BLE Serial Queue.

By doing so, analyze how the original Delegate-based architecture works and establish a baseline for improving its overall structure.

---

## Overview

CoreBluetooth provides a Delegate-based API and allows developers to specify the execution queue for Delegate callbacks through `CBCentralManager(delegate:queue:)`.

When the `queue` parameter is set to `nil`, Delegate callbacks are executed on the **Main Queue**, meaning BLE event handling shares the same execution context as UI rendering and user interactions.

<img width="600" alt="image" src="https://github.com/user-attachments/assets/d78f2d46-6868-41da-a0e6-c7f287e8f8e4" />

In the original implementation, BLE event handling, state updates, and logging were all performed directly inside Delegate callbacks.

```swift
if !model.discovered.contains(where: { $0.id == item.id }) {
    model.discovered.append(item)
    model.addLog("Found: \(name)")
}
```

As a result, event generation and state management were tightly coupled within the same callbacks. Since state updates were spread across multiple Delegate callbacks, it became difficult to trace the overall event flow. In addition, running Delegate callbacks on the Main Queue caused BLE event processing to share the same execution context as UI-related work.

To address these issues, two architectural improvements were introduced.

### 1. Event Stream with AsyncStream

Delegate callbacks were modified to emit BLE events through `AsyncStream` instead of directly updating application state.

```swift
enum CentralBLEEvent {
    case discovered(DiscoveredPeripheral, log: String)
    case statusChanged(String, log: String)
    case log(String)
}
```

```swift
continuation?.yield(
    .discovered(
        item,
        log: "Found: \(name)"
    )
)
```

The event consumer receives BLE events through `for await` and updates the application state according to each event type. This keeps Delegate callbacks focused on event production while centralizing state management in a single location.

```swift
for await event in manager.events {
    switch event {
    case .bluetoothStateChanged(let state, let log):
        model.bluetoothStateText = state
        model.addLog(log)

    case .advertisingChanged(let isAdvertising, let log):
        model.isAdvertising = isAdvertising
        model.addLog(log)

    case .log(let message):
        model.addLog(message)

    case .answerReceived(let centralID, let isGood):
        model.receiveAnswer(from: centralID, value: isGood)
    }
}
```

### 2. Dedicated BLE Serial Queue

The `queue` parameter of `CBCentralManager(delegate:queue:)` was changed from `nil` to a dedicated BLE Serial Queue.

```swift
private let bleQueue = DispatchQueue(label: "ble.serial.queue")

centralManager = CBCentralManager(
    delegate: self,
    queue: bleQueue
)
```

This separated BLE Delegate callbacks from UI-related work by placing them in different execution contexts.

As a result,

- `AsyncStream` separates event generation from state management.
- A dedicated BLE Serial Queue separates BLE event processing from UI execution.

Together, these changes provide a CoreBluetooth architecture that integrates more naturally with Swift Concurrency.

---

## Learning Goals

- Transform the Delegate-based CoreBluetooth API into a Swift Concurrency event stream using `AsyncStream`.
- Separate Delegate callbacks from state management to improve readability and maintainability.
- Understand how the `queue` parameter of `CBCentralManager` determines the execution context of Delegate callbacks.
- Compare BLE callback behavior between the Main Queue and a Background Serial Queue.
- Design and implement a Swift Concurrency-based BLE event processing architecture.

---

## Flow

### Before: Delegate-based

```text
didDiscover()
 ├─ discovered.append()
 └─ addLog()

didConnect()
 ├─ status = Connected
 └─ addLog()

didDiscoverCharacteristicsFor()
 ├─ status = Ready
 └─ addLog()
```

### After: AsyncStream-based

```text
didDiscover()
 └─ yield(.discovered)

didConnect()
 └─ yield(.statusChanged)

didDiscoverCharacteristicsFor()
 └─ yield(.statusChanged)

        ↓

for await event in manager.events {
    // update state
    // add log
}
```

| Delegate-based | AsyncStream-based |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/52f6e58e-58dc-44ae-b4e7-20814764d014" width="400"> | <img src="https://github.com/user-attachments/assets/ea50e826-c0bc-49ed-b234-b4e3d4e894af" width="400"> |
| Delegate Callback 내부에서 상태 변경과 로그 기록을 직접 수행 | Delegate Callback은 이벤트만 생성하고 상태 변경은 Consumer에서 처리 |


---

# Experiment 1: AsyncStream

## Problem

BLE event handling and state updates were tightly coupled inside Delegate callbacks.

As a result, the Manager needed to know how the Model managed its state, making event generation and state management strongly coupled.

## Approach

The Delegate pattern remained unchanged, but Delegate callbacks were modified to emit events through `AsyncStream` instead of directly updating state.

```swift
continuation?.yield(.discovered(item, log: "Found: \(name)"))
```

The Manager now only produces events, while state updates are handled by the event consumer.

## Result

| Before | After |
| --- | --- |
| State updates inside Delegate callbacks | Delegate callbacks only emit events |
| Manager updates Model state | Manager acts only as an event producer |
| State updates scattered across callbacks | Events processed sequentially by the consumer |
| Difficult to follow event flow | `for await` provides a clear event flow |
| Limited integration with Swift Concurrency | Naturally integrated with AsyncSequence |

---

# Experiment 2: Delegate Queue

## Problem

When `queue` is `nil`, Delegate callbacks are executed on the Main Queue.

As a result, BLE callbacks share the same execution context as UI rendering, user interaction, and Timer events.

Under heavy Main Thread load, BLE callbacks may also be delayed because they must wait for the Main Queue to become available.

## Approach

The `queue` parameter of `CBCentralManager(delegate:queue:)` was changed from `nil` to a dedicated BLE Serial Queue.

```swift
private let bleQueue = DispatchQueue(label: "ble.serial.queue")
```

A Timer was also introduced to continuously generate workload on the Main Thread, allowing callback timing to be compared between `queue: nil` and `queue: bleQueue`.

---

## Threading Flow

### Before

```text
Main Thread
├── UI Rendering
├── User Interaction
├── Main Thread Stress (Timer)
└── BLE Delegate Callback
```

### After

```text
Main Thread
├── UI Rendering
├── User Interaction
└── Main Thread Stress (Timer)

BLE Queue
└── BLE Delegate Callback
```

---

## Results

### Timer Interval Comparison

| Timer Interval | Result | Write Response |
| --- | --- | --- |
| `0.03 sec` | Most callbacks were processed around **0.064 sec** |<img src="https://github.com/user-attachments/assets/9c06cfa2-ce95-47c3-bcc7-90834dd9b32a" width="220"> |
| `0.016 sec` | Most callbacks were processed around **0.127 sec** | <img src="https://github.com/user-attachments/assets/9a3d12ba-9653-45fc-a906-da74a9b7427a" width="220"> |

When Delegate callbacks were executed on the Main Queue, callback timing tended to follow the Main Thread scheduling.

This indicates that callback execution was influenced by Main Thread workload rather than BLE communication speed itself.

### Queue Comparison

| Main Queue (`queue: nil`) | Background Serial Queue (`queue: bleQueue`) |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/b1500fab-057e-41d0-ac20-1cea0dbd4007" width="200"> | <img src="https://github.com/user-attachments/assets/8fcddeeb-a003-4460-942d-08757e0d532ea" width="200"> |
| Most callbacks around `0.064 sec` | Responses observed between `0.035 ~ 0.063 sec` |
| Dependent on Main Thread workload | Processed independently of Main Thread |
| Shared execution context with UI | Separate execution context for BLE callbacks |

---

### Main Queue (`queue: nil`)

- Delegate callbacks execute on the Main Thread.
- BLE callbacks share the same execution context as UI rendering, user interaction, and Timer events.
- Callback execution tends to wait until Main Thread tasks are processed.
- Most Write Response callbacks appeared around **0.064 sec**.

### Background Serial Queue

- Delegate callbacks execute on a dedicated BLE Serial Queue.
- BLE callbacks are processed independently of Main Thread tasks.
- Responses between **0.035 ~ 0.063 sec** were observed.
- BLE callbacks were less affected by Main Thread workload.

---

## Findings

- Delegate-based CoreBluetooth APIs can be naturally integrated with Swift Concurrency using `AsyncStream`.
- Delegate callbacks now focus only on event generation, while state management is handled by the event consumer.
- BLE events from multiple Delegate callbacks are unified into a single asynchronous event stream.
- `for await` provides a clear and sequential event flow.
- The `queue` parameter determines where Delegate callbacks execute—it does **not** improve BLE communication speed.
- A dedicated BLE Serial Queue reduces the impact of Main Thread workload on BLE callback execution.
- Combining `AsyncStream` with a dedicated Serial Queue results in a clearer event flow and threading model.

---

## Conclusion

This project demonstrates that CoreBluetooth's Delegate-based API can be integrated into Swift Concurrency by transforming Delegate callbacks into an `AsyncStream`-based event flow.

In addition, moving Delegate callbacks from the Main Queue to a dedicated BLE Serial Queue separates BLE event processing from UI-related work.

The experiment also showed that, under Main Thread load, BLE callbacks executed on a dedicated Serial Queue were less affected by UI work, resulting in a more stable and predictable event processing flow.


<details>
<summary>한국어 번역</summary>


## Big Idea

**Swift Concurrency**

---

## Essential Question

1. Delegate 기반 CoreBluetooth API를 Swift Concurrency의 비동기 이벤트 흐름으로 변환하면 어떤 장점이 있을까?

2. BLE Delegate Callback을 Main Queue가 아닌 전용 Serial Queue에서 처리하면 Threading Model은 어떻게 달라질까?

---

## Challenge

Delegate Callback 기반 CoreBluetooth 구조와 Swift Concurrency 기반 구조를 비교하며 코드 가독성, 안정성, 유지보수성, Threading Model을 분석한다.

---

## Challenge Statement

`AsyncStream`과 BLE 전용 Serial Queue를 활용한 이벤트 기반 CoreBluetooth 아키텍처를 설계하고 구현한다.

이를 통해 기존 CoreBluetooth Delegate 기반 구조가 어떤 방식으로 동작하는지 분석하고, 이후 구조 개선의 기준으로 활용한다.

---

## Overview

CoreBluetooth는 Delegate 기반 API를 제공하며, `CBCentralManager(delegate:queue:)`를 통해 Delegate Callback이 실행될 Queue를 개발자가 직접 지정할 수 있다.
기본적으로 queue를 `nil`로 설정하면 Delegate Callback은 Main Queue에서 실행되며, BLE 이벤트 처리와 UI Rendering, 사용자 입력 처리 등이 동일한 실행 컨텍스트를 공유한다.

<img width="600" alt="image" src="https://github.com/user-attachments/assets/d78f2d46-6868-41da-a0e6-c7f287e8f8e4" />


기존 구현에서는 BLE 이벤트 처리, 상태 변경, 로그 기록이 Delegate Callback 내부에서 함께 수행되었다.

```swift
if !model.discovered.contains(where: { $0.id == item.id }) {
    model.discovered.append(item)
    model.addLog("Found: \(name)")
}
```
이 구조에서는 이벤트 생성과 상태 관리가 하나의 Callback 안에 결합되어 있었고, 상태 변경 로직이 여러 Delegate Callback에 분산되어 전체 이벤트 흐름을 추적하기 어려웠다. 또한 Delegate Callback이 Main Queue에서 실행되므로 UI 작업과 BLE 이벤트 처리가 동일한 실행 컨텍스트를 공유하게 된다.

이를 개선하기 위해 두 가지 구조 변경을 적용하였다.

### 1. AsyncStream을 이용한 이벤트 스트림

Delegate Callback은 상태를 직접 변경하지 않고 AsyncStream을 통해 BLE 이벤트만 생성하도록 변경하였다.

```swift
enum CentralBLEEvent {
    case discovered(DiscoveredPeripheral, log: String)
    case statusChanged(String, log: String)
    case log(String)
}
```

```swift
continuation?.yield(
    .discovered(
        item,
        log: "Found: \(name)"
    )
)
```

`for await`를 통해 전달된 BLE 이벤트를 소비하면서 이벤트 종류에 따라 상태를 갱신한다. 이를 통해 Delegate는 이벤트 생성만 담당하고, 상태 관리는 하나의 소비 영역에서 일관되게 처리할 수 있다.

```swift
for await event in manager.events {
    switch event {
    case .bluetoothStateChanged(let state, let log):
        model.bluetoothStateText = state
        model.addLog(log)

    case .advertisingChanged(let isAdvertising, let log):
        model.isAdvertising = isAdvertising
        model.addLog(log)

    case .log(let message):
        model.addLog(message)

    case .answerReceived(let centralID, let isGood):
        model.receiveAnswer(from: centralID, value: isGood)
    }
}
```

### 2. BLE 전용 Serial Queue 적용

또한 CBCentralManager(delegate:queue:)의 queue를 nil에서 BLE 전용 Serial Queue로 변경하였다.

```swift
private let bleQueue = DispatchQueue(label: "ble.serial.queue")

centralManager = CBCentralManager(
    delegate: self,
    queue: bleQueue
)
```

이를 통해 BLE Delegate Callback과 UI 작업을 서로 다른 실행 컨텍스트에서 처리하도록 구성하였다.

결과적으로,

AsyncStream은 이벤트 생성과 상태 관리의 책임을 분리하고,
BLE 전용 Serial Queue는 BLE 이벤트 처리와 UI 작업의 실행 컨텍스트를 분리하여,

CoreBluetooth를 Swift Concurrency와 더욱 자연스럽게 연결할 수 있는 구조를 구현하였다.

---

## Learning Goal

- Delegate 기반 CoreBluetooth API를 `AsyncStream`을 이용해 Swift Concurrency 기반 이벤트 스트림으로 변환한다.
- Delegate Callback과 상태 관리의 책임을 분리하여 코드의 가독성과 유지보수성을 향상시킨다.
- `CBCentralManager`의 `queue`가 Delegate Callback 실행 컨텍스트를 결정한다는 점을 이해한다.
- Main Queue와 Background Serial Queue에서 BLE Callback의 동작 차이를 비교한다.
- Swift Concurrency 기반 BLE 이벤트 처리 구조를 설계하고 구현한다.

---

## Flow

### Before: Delegate-based

```
didDiscover()
 ├─ discovered.append()
 └─ addLog()

didConnect()
 ├─ status = Connected
 └─ addLog()

didDiscoverCharacteristicsFor()
 ├─ status = Ready
 └─ addLog()
```

### After: AsyncStream-based

```
didDiscover()
 └─ yield(.discovered)

didConnect()
 └─ yield(.statusChanged)

didDiscoverCharacteristicsFor()
 └─ yield(.statusChanged)

        ↓

for await event in manager.events {
    // update state
    // add log
}
```

| Delegate-based | AsyncStream-based |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/52f6e58e-58dc-44ae-b4e7-20814764d014" width="400"> | <img src="https://github.com/user-attachments/assets/ea50e826-c0bc-49ed-b234-b4e3d4e894af" width="400"> |
| Delegate Callback 내부에서 상태 변경과 로그 기록을 직접 수행 | Delegate Callback은 이벤트만 생성하고 상태 변경은 Consumer에서 처리 |

---

## Experiment 1: AsyncStream 적용

### Problem

기존 구조에서는 BLE 이벤트 처리와 상태 변경이 Delegate Callback 내부에 함께 존재했다.

이로 인해 Manager가 Model의 상태 변경 방식까지 알고 있어야 했고, 이벤트 발생 위치와 상태 변경 위치가 강하게 결합되어 있었다.

### Approach

Delegate 구조는 유지하되, Delegate Callback에서 직접 상태를 변경하지 않고 `AsyncStream`을 통해 이벤트를 전달하도록 변경하였다.

```swift
continuation?.yield(.discovered(item, log: "Found: \(name)"))
```

이 구조에서는 Manager가 상태를 직접 변경하지 않고 이벤트만 발생시킨다.

즉, Manager는 Model을 알 필요가 없고, 상태 변경은 이벤트를 소비하는 ViewModel 또는 Consumer 영역에서 처리된다.

### Result

| Before | After |
| --- | --- |
| Delegate Callback 내부에서 상태 변경 | Delegate Callback은 이벤트만 생성 |
| Manager가 Model 상태 변경에 관여 | Manager는 이벤트 생산자 역할만 수행 |
| 상태 변경 로직이 여러 Callback에 분산 | 이벤트 소비 영역에서 순차적으로 처리 |
| 흐름 추적이 어려움 | `for await`로 흐름 추적이 쉬움 |
| Swift Concurrency와 연결이 어색함 | AsyncSequence 흐름으로 자연스럽게 연결 |

---

## Experiment 2: Delegate Queue 분리

### Problem

`CBCentralManager(delegate:queue:)`에서 `queue`를 `nil`로 설정하면 Delegate Callback은 기본적으로 Main Queue에서 실행된다.

이 경우 BLE 이벤트 처리와 UI 렌더링, 사용자 입력 처리, Timer 작업 등이 모두 Main Thread에서 함께 처리된다.

평소에는 Callback 작업이 가볍기 때문에 차이가 크지 않을 수 있다. 하지만 Main Thread에 부하가 발생하면 BLE Callback도 Main Queue가 비워질 때까지 기다릴 수 있다.

### Approach

`CBCentralManager(delegate:queue:)`의 `queue`를 `nil`에서 BLE 전용 Serial DispatchQueue로 변경하였다.

```swift
private let bleQueue = DispatchQueue(label: "ble.serial.queue")

centralManager = CBCentralManager(
    delegate: self,
    queue: bleQueue
)
```

그리고 Timer를 사용해 Main Thread에 지속적인 부하를 발생시키며 `queue: nil`과 `queue: bleQueue`의 BLE Write Response 시간을 비교하였다.

---

## Threading Flow

### Before: Main Queue

```
Main Thread
├── UI Rendering
├── User Interaction
├── Main Thread Stress (Timer)
└── BLE Delegate Callback
```

### After: Background Serial Queue

```
Main Thread
├── UI Rendering
├── User Interaction
└── Main Thread Stress (Timer)

BLE Queue
└── BLE Delegate Callback
```

| Main Queue (`queue: nil`) | Background Serial Queue (`queue: bleQueue`) |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/ad6da4fb-bf94-4bd0-89bc-b6d95166994e" width="400"> | <img src="https://github.com/user-attachments/assets/8ec7b75a-217c-4844-a051-8909023525ba" width="400"> |
| UI 작업과 BLE Callback이 Main Thread를 공유 | BLE Callback이 Main Thread와 분리된 Queue에서 실행 |

---

## Timer Interval에 따른 결과

Main Thread에 Timer를 이용해 부하를 준 뒤 BLE Write Response 시간을 비교하였다.

| Timer Interval | Result | Write Response |
| :---: | :--- | :---: |
| `0.03 sec` | 대부분의 Callback이 약 **0.064 sec** 부근에서 처리 | <img src="https://github.com/user-attachments/assets/9c06cfa2-ce95-47c3-bcc7-90834dd9b32a" width="220"> |
| `0.016 sec` | 대부분의 Callback이 약 **0.127 sec** 부근에서 처리 | <img src="https://github.com/user-attachments/assets/9a3d12ba-9653-45fc-a906-da74a9b7427a" width="220"> |

`queue: nil`에서는 Delegate Callback이 Main Queue에서 실행되기 때문에 Timer가 생성하는 Main Thread 작업이 먼저 처리된 후 Callback이 실행되는 경향을 보였다.

특히 `Timer(withTimeInterval: 0.016)` 환경에서는 대부분의 Callback이 약 `0.127 sec` 부근에서 거의 동일하게 처리되었다.

이는 BLE 통신 시간이 항상 동일해서라기보다는, Delegate Callback의 실행 시점이 Main Thread의 작업 스케줄에 영향을 받기 때문이다.

---

## Queue 비교 결과

| Main Queue (`queue: nil`) | Background Serial Queue (`queue: bleQueue`) |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/b1500fab-057e-41d0-ac20-1cea0dbd4007" width="200"> | <img src="https://github.com/user-attachments/assets/8fcddeeb-a003-4460-942d-08757e0d532ea" width="200"> |
| 대부분 `0.064 sec` 부근에서 callback 처리	 |`0.035 ~ 0.063 sec` 구간의 응답도 관찰 |
| Main Thread 작업이 끝난 뒤 Callback이 실행되는 경향 | Main Thread와 분리되어 Callback 처리 |
| UI 작업과 Timer 부하의 영향을 받음 | UI 작업의 영향을 상대적으로 덜 받음 |

### Main Queue (`queue: nil`)

- Delegate Callback이 Main Thread에서 실행된다.
- UI Rendering, User Interaction, Timer 작업과 같은 Main Thread 작업과 동일한 실행 컨텍스트를 공유한다.
- Main Thread 작업이 먼저 처리된 이후 BLE Callback이 실행되는 경향이 있다.
- 실험에서는 대부분의 Write Response Callback이 약 `0.064 sec` 부근에서 거의 동일하게 나타났다.

### Background Serial Queue (`queue: bleQueue`)

- Delegate Callback이 BLE 전용 Serial Queue에서 실행된다.
- Main Thread 작업과 독립적으로 Callback을 처리할 수 있다.
- 실험에서는 `0.035 ~ 0.063 sec` 범위의 응답도 관찰되었다.
- Main Thread 부하 상황에서도 BLE Callback을 보다 효율적으로 처리할 수 있다.

---

## Experimental View

| Central | Peripheral |
| --- | --- |
| <img src="https://github.com/user-attachments/assets/183e88f9-0cf0-40eb-a82e-5d1aec1d8778" width="200"> | <img src="https://github.com/user-attachments/assets/7d317f52-7f1f-4e58-a63b-7d178954cefb" width="200"> |

---

## Findings

- Delegate 기반 CoreBluetooth API도 `AsyncStream`을 사용하면 Swift Concurrency의 비동기 이벤트 흐름으로 자연스럽게 변환할 수 있었다.
- Delegate Callback은 이벤트 생성 역할만 담당하고, 상태 변경과 로그 기록은 이벤트 소비 영역에서 처리하도록 책임을 분리할 수 있었다.
- 여러 Delegate Callback에서 발생하는 BLE 이벤트를 하나의 Event Stream으로 통합하여 흐름을 추적하기 쉬워졌다.
- `for await`를 사용하면 BLE 이벤트를 순차적으로 처리할 수 있어 Swift Concurrency 패턴과 자연스럽게 연결된다.
- `CBCentralManager`의 `queue`는 BLE 통신 속도를 높이는 옵션이 아니라, Delegate Callback이 실행될 Queue를 결정하는 옵션이다.
- Main Queue에서는 Delegate Callback이 Main Thread의 작업 스케줄에 영향을 받아 특정 시간 부근에서 반복적으로 처리되는 경향을 보였다.
- BLE 전용 Serial Queue를 사용하면 Callback이 Main Thread와 독립적으로 실행되어 UI 작업이나 Timer 부하의 영향을 상대적으로 덜 받는다.
- CoreBluetooth와 같은 Delegate 기반 API도 Swift Concurrency와 함께 사용할 때 이벤트 흐름과 Threading Model을 더욱 명확하게 설계할 수 있음을 확인하였다.

---

## Conclusion

이번 실험을 통해 CoreBluetooth의 Delegate 기반 API를 `AsyncStream`으로 변환하여 Swift Concurrency의 이벤트 흐름으로 통합할 수 있음을 확인하였다.

또한 Delegate Callback의 실행 Queue를 Main Queue에서 BLE 전용 Serial Queue로 분리함으로써, UI 작업과 BLE 이벤트 처리를 서로 다른 실행 컨텍스트에서 관리할 수 있었다.
전용 Serial Queue를 사용할 경우 Main Thread의 부하가 있는 상황에서도 BLE Callback이 UI 작업의 영향을 상대적으로 덜 받는 것을 확인하였다.



</details>
