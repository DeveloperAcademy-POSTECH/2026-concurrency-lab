//
//  CentralBLEManager.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import Foundation
import CoreBluetooth

enum CentralBLEEvent {
    case bluetoothStateChanged(String, log: String)
    case discovered(DiscoveredPeripheral, log: String)
    case discoveredCleared(log: String)
    case statusChanged(String, log: String)
    case log(String)
}

final class CentralBLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var centralManager: CBCentralManager?
    private var targetPeripheral: CBPeripheral?
    private var answerCharacteristic: CBCharacteristic?

    private var pendingAnswer: BLEAnswer?
    private var discoveredIDs: Set<UUID> = []

    private var continuation: AsyncStream<CentralBLEEvent>.Continuation?

    lazy var events = AsyncStream<CentralBLEEvent> { continuation in
        self.continuation = continuation
    }

    override init() {
        super.init()

        self.centralManager = CBCentralManager(
            delegate: self,
            queue: nil
        )
    }

    // MARK: - 블루투스 상태 관리

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Powered On",
                    log: "블루투스 활성화"
                )
            )

        case .poweredOff:
            continuation?.yield(
                .bluetoothStateChanged(
                    "Powered Off",
                    log: "블루투스 비활성화"
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
                    "Bluetooth not ready",
                    log: "알 수 없는 블루투스 상태"
                )
            )
        }
    }

    // MARK: - 기기 검색

    func scan() {
        guard centralManager?.state == .poweredOn else {
            continuation?.yield(.log("블루투스 상태가 올바르지 않음"))
            return
        }

        discoveredIDs.removeAll()

        continuation?.yield(
            .discoveredCleared(log: "Scanning...")
        )

        centralManager?.scanForPeripherals(
            withServices: nil,
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )
    }

    func stopScan() {
        centralManager?.stopScan()
        continuation?.yield(.log("Scan stopped"))
    }

    // MARK: - 연결 관리

    func connect(to item: DiscoveredPeripheral) {
        targetPeripheral = item.peripheral
        targetPeripheral?.delegate = self

        centralManager?.stopScan()
        centralManager?.connect(item.peripheral, options: nil)

        continuation?.yield(
            .statusChanged(
                "Connecting...",
                log: "Connecting to \(item.name)"
            )
        )
    }

    func disconnect() {
        if let peripheral = targetPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }

        targetPeripheral = nil
        answerCharacteristic = nil

        continuation?.yield(
            .statusChanged(
                "Disconnected",
                log: "Disconnected"
            )
        )
    }

    // MARK: - 데이터 전송

    func send(_ answer: BLEAnswer) {
        guard let peripheral = targetPeripheral,
              let characteristic = answerCharacteristic
        else {
            pendingAnswer = answer
            continuation?.yield(.log("아직 연결 준비 안 됨"))
            return
        }

        let data = Data([answer.rawValue])

        peripheral.writeValue(
            data,
            for: characteristic,
            type: .withResponse
        )

        continuation?.yield(
            .statusChanged(
                "Sent \(answer == .good ? "조아용" : "시러용")",
                log: "Sent \(answer == .good ? "조아용" : "시러용")"
            )
        )
    }

    // MARK: - CBCentralManagerDelegate

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        let name =
            peripheral.name
            ?? advertisementData[CBAdvertisementDataLocalNameKey] as? String
            ?? "Unknown"

        let item = DiscoveredPeripheral(
            id: peripheral.identifier,
            name: name,
            rssi: RSSI.intValue,
            peripheral: peripheral
        )

        guard !discoveredIDs.contains(item.id) else { return }

        discoveredIDs.insert(item.id)

        continuation?.yield(
            .discovered(
                item,
                log: "Found: \(name)"
            )
        )
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        continuation?.yield(
            .statusChanged(
                "Connected",
                log: "iPhone과 연결"
            )
        )

        peripheral.discoverServices([BLEUUID.service])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        continuation?.yield(
            .statusChanged(
                "Connect failed",
                log: "Connect failed: \(error?.localizedDescription ?? "unknown")"
            )
        )
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        continuation?.yield(
            .statusChanged(
                "Disconnected",
                log: "Disconnected"
            )
        )

        targetPeripheral = nil
        answerCharacteristic = nil
    }

    // MARK: - CBPeripheralDelegate

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error {
            continuation?.yield(
                .log("Discover services error: \(error.localizedDescription)")
            )
            return
        }

        guard let services = peripheral.services else { return }

        for service in services where service.uuid == BLEUUID.service {
            peripheral.discoverCharacteristics(
                [BLEUUID.answer],
                for: service
            )
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error {
            continuation?.yield(
                .log("Discover characteristics error: \(error.localizedDescription)")
            )
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics where characteristic.uuid == BLEUUID.answer {
            answerCharacteristic = characteristic

            continuation?.yield(
                .statusChanged(
                    "Ready",
                    log: "Ready to send"
                )
            )

            if let pendingAnswer {
                self.pendingAnswer = nil
                send(pendingAnswer)
            }
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error {
            continuation?.yield(
                .statusChanged(
                    "Write failed",
                    log: "Write failed: \(error.localizedDescription)"
                )
            )
        } else {
            continuation?.yield(
                .statusChanged(
                    "Write success",
                    log: "쓰기 성공"
                )
            )
        }
    }
}
