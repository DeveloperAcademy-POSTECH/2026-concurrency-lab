//
//  CentralBLEManager.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import Foundation
import CoreBluetooth

final class CentralBLEManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    private var centralManager: CBCentralManager?
    private var targetPeripheral: CBPeripheral?
    private var answerCharacteristic: CBCharacteristic?

    private let model: CentralBLEModel
    private var pendingAnswer: BLEAnswer?

    init(model: CentralBLEModel) {
        self.model = model
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
            model.status = "Powered On"
            model.addLog("블루투스 활성화")

        case .poweredOff:
            model.status = "Powered Off"
            model.addLog("블루투스 비활성화")

        case .unauthorized:
            model.status = "Unauthorized"
            model.addLog("블루투스 권한 없음")

        case .unsupported:
            model.status = "Unsupported"
            model.addLog("이 기기는 블루투스를 지원하지 않음")

        case .resetting:
            model.status = "Resetting"

        case .unknown:
            model.status = "Unknown"

        @unknown default:
            model.status = "Bluetooth not ready"
        }
    }
    
    // MARK: - 기기 검색

    func scan() {
        guard centralManager?.state == .poweredOn else {
            model.addLog("블루투스 상태가 올바르지 않음")
            return
        }

        model.discovered.removeAll()
        model.addLog("Scanning...")

        centralManager?.scanForPeripherals(
            withServices: nil,
            options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true
            ]
        )
    }

    func stopScan() {
        centralManager?.stopScan()
        model.addLog("Scan stopped")
    }
    
    // MARK: - 연결 관리

    func connect(to item: DiscoveredPeripheral) {
        targetPeripheral = item.peripheral
        targetPeripheral?.delegate = self

        centralManager?.stopScan()
        centralManager?.connect(item.peripheral, options: nil)

        model.status = "Connecting..."
        model.addLog("Connecting to \(item.name)")
    }

    func disconnect() {
        if let peripheral = targetPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }

        targetPeripheral = nil
        answerCharacteristic = nil
        model.status = "Disconnected"
        model.addLog("Disconnected")
    }
    
    // MARK: - 데이터 전송

    func send(_ answer: BLEAnswer) {
        guard let peripheral = targetPeripheral,
              let characteristic = answerCharacteristic
        else {
            pendingAnswer = answer
            model.addLog("아직 연결 준비 안 됨")
            return
        }

        let data = Data([answer.rawValue])

        peripheral.writeValue(
            data,
            for: characteristic,
            type: .withResponse
        )

        model.status = "Sent \(answer == .good ? "조아용" : "시러용")"
        model.addLog("Sent \(answer == .good ? "조아용" : "시러용")")
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

        if !model.discovered.contains(where: { $0.id == item.id }) {
            model.discovered.append(item)
            model.addLog("Found: \(name)")
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        model.status = "Connected"
        model.addLog("iPhone과 연결")

        peripheral.discoverServices([BLEUUID.service])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        model.status = "Connect failed"
        model.addLog("Connect failed: \(error?.localizedDescription ?? "unknown")")
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        model.status = "Disconnected"
        model.addLog("Disconnected")

        targetPeripheral = nil
        answerCharacteristic = nil
    }
    
    // MARK: - CBPeripheralDelegate

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        if let error {
            model.addLog("Discover services error: \(error.localizedDescription)")
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
            model.addLog("Discover characteristics error: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics where characteristic.uuid == BLEUUID.answer {
            answerCharacteristic = characteristic
            model.status = "Ready"
            model.addLog("Ready to send")

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
            model.status = "Write failed"
            model.addLog("Write failed: \(error.localizedDescription)")
        } else {
            model.status = "Write success"
            model.addLog("쓰기 성공")
        }
    }
}
