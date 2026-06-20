//
//  PeripheralBLEManager.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import Foundation
import CoreBluetooth

final class PeripheralBLEManager: NSObject, CBPeripheralManagerDelegate {

    private var peripheralManager: CBPeripheralManager?
    private var answerCharacteristic: CBMutableCharacteristic?

    private let model: PeripheralBLEModel

    init(model: PeripheralBLEModel) {
        self.model = model
        super.init()

        self.peripheralManager = CBPeripheralManager(
            delegate: self,
            queue: nil
        )
    }
    
    //MARK: - 블루투스 상태 관리

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            model.bluetoothStateText = "Powered On"
            model.addLog("블루투스가 활성화")
            setupService()
            startAdvertising()

        case .poweredOff:
            model.bluetoothStateText = "Powered Off"
            model.addLog("블루투스가 비활성화")

        case .unauthorized:
            model.bluetoothStateText = "Unauthorized"
            model.addLog("블루투스 권한 없음")

        case .unsupported:
            model.bluetoothStateText = "Unsupported"
            model.addLog("이 기기는 블루투스를 지원하지 않음")

        case .resetting:
            model.bluetoothStateText = "Resetting"

        case .unknown:
            model.bluetoothStateText = "Unknown"

        @unknown default:
            model.bluetoothStateText = "Unknown Default"
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

        model.addLog("Service added")
    }
    
    // MARK: - Advertising 관리

    func startAdvertising() {
        guard let peripheralManager else { return }

        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [BLEUUID.service],
            CBAdvertisementDataLocalNameKey: "Answer-iPhone"
        ])

        model.isAdvertising = true
        model.addLog("Advertising started")
    }

    func stopAdvertising() {
        peripheralManager?.stopAdvertising()
        model.isAdvertising = false
        model.addLog("Advertising stopped")
    }

    func peripheralManagerDidStartAdvertising(
        _ peripheral: CBPeripheralManager,
        error: Error?
    ) {
        if let error {
            model.addLog("Advertising error: \(error.localizedDescription)")
        } else {
            model.addLog("Advertising success")
        }
    }

    // MARK: - 데이터 수신
    
    func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        for request in requests {
            guard request.characteristic.uuid == BLEUUID.answer else {
                peripheral.respond(to: request, withResult: .requestNotSupported)
                continue
            }

            guard let firstByte = request.value?.first else {
                peripheral.respond(to: request, withResult: .invalidAttributeValueLength)
                continue
            }

            let isGood = firstByte == BLEAnswer.good.rawValue
            let centralID = request.central.identifier

            DispatchQueue.main.async {
                self.model.receiveAnswer(from: centralID, value: isGood)
            }

            peripheral.respond(to: request, withResult: .success)
        }
    }
}
