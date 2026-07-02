//
//  PeripheralBLEManager.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import Foundation
import CoreBluetooth

enum AdvertisingState {
    case started
    case stopped
    case failed(Error)
}

enum PeripheralAnswer {
    case received(centralID: UUID, answer: BLEAnswer)
    case invalidValueLength(central: CBCentral)
    case unsupportedRequest(central: CBCentral)
}

enum PeripheralBLEEvent {
    case bluetoothStateChanged(String, log: String)
    case advertisingChanged(
        AdvertisingState,
        peripheral: CBPeripheralManager
    )
    case answerReceived(PeripheralAnswer)
    case log(String)
}

final class PeripheralBLEManager: NSObject, CBPeripheralManagerDelegate {

    private var peripheralManager: CBPeripheralManager?
    private var answerCharacteristic: CBMutableCharacteristic?

    private var continuation: AsyncStream<PeripheralBLEEvent>.Continuation?

    lazy var events = AsyncStream<PeripheralBLEEvent> { continuation in
        self.continuation = continuation
    }

    override init() {
        super.init()

        self.peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
    }

    // MARK: - 블루투스 상태 관리

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Powered On",
                    log: "블루투스가 활성화"
                )
            )

            setupService()
            startAdvertising()

        case .poweredOff:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Powered Off",
                    log: "블루투스가 비활성화"
                )
            )

        case .unauthorized:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Unauthorized",
                    log: "블루투스 권한 없음"
                )
            )

        case .unsupported:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Unsupported",
                    log: "이 기기는 블루투스를 지원하지 않음"
                )
            )

        case .resetting:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Resetting",
                    log: "블루투스 상태 재설정 중"
                )
            )

        case .unknown:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Unknown",
                    log: "블루투스 상태 알 수 없음"
                )
            )

        @unknown default:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Unknown Default",
                    log: "알 수 없는 블루투스 상태"
                )
            )
        }
    }

    // MARK: - 서비스 설정

    private func setupService() {
        guard let peripheralManager else { return }

        let characteristic = CBMutableCharacteristic(
            type: BLEUUID.answer,
            properties: [.write, .writeWithoutResponse],
            value: nil,
            permissions: [.writeable]
        )

        self.answerCharacteristic = characteristic

        let service = CBMutableService(
            type: BLEUUID.service,
            primary: true
        )

        service.characteristics = [characteristic]

        peripheralManager.removeAllServices()
        peripheralManager.add(service)

        continuation?.yield(.log("Service added"))
    }

    // MARK: - Advertising 관리

    func startAdvertising() {
        guard let peripheralManager else { return }

        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [BLEUUID.service],
            CBAdvertisementDataLocalNameKey: "Answer-iPhone"
        ])

        continuation?.yield(
            .advertisingChanged(
                .started,
                peripheral: peripheralManager
            )
        )
    }

    func stopAdvertising() {
        guard let peripheralManager else { return }

        peripheralManager.stopAdvertising()

        continuation?.yield(
            .advertisingChanged(
                .stopped,
                peripheral: peripheralManager
            )
        )
    }

    func peripheralManagerDidStartAdvertising(
        _ peripheral: CBPeripheralManager,
        error: Error?
    ) {
        if let error {
            continuation?.yield(
                .advertisingChanged(
                    .failed(error),
                    peripheral: peripheral
                )
            )
        } else {
            continuation?.yield(.log("Advertising success"))
        }
    }

    // MARK: - 데이터 수신

    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        for request in requests {
            guard request.characteristic.uuid == BLEUUID.answer else {
                continuation?.yield(
                    .answerReceived(
                        .unsupportedRequest(central: request.central)
                    )
                )

                peripheral.respond(
                    to: request,
                    withResult: .requestNotSupported
                )
                continue
            }

            guard let firstByte = request.value?.first else {
                continuation?.yield(
                    .answerReceived(
                        .invalidValueLength(central: request.central)
                    )
                )

                peripheral.respond(
                    to: request,
                    withResult: .invalidAttributeValueLength
                )
                continue
            }

            let answer = BLEAnswer(rawValue: firstByte)
            let centralID = request.central.identifier

            if let answer {
                continuation?.yield(
                    .answerReceived(
                        .received(
                            centralID: centralID,
                            answer: answer
                        )
                    )
                )

                peripheral.respond(to: request, withResult: .success)
            } else {
                continuation?.yield(
                    .answerReceived(
                        .invalidValueLength(central: request.central)
                    )
                )

                peripheral.respond(
                    to: request,
                    withResult: .invalidAttributeValueLength
                )
            }
        }
    }
}
