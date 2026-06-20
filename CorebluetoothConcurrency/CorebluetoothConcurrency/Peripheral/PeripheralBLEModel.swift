//
//  PeripheralBLEModel.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import Foundation
import Observation

@Observable
final class PeripheralBLEModel {
    var isAdvertising: Bool = false
    var bluetoothStateText: String = "Unknown"
    var answers: [UUID: Bool] = [:]
    var logs: [String] = []

    func receiveAnswer(from id: UUID, value: Bool) {
        answers[id] = value
        logs.insert("\(id.uuidString.prefix(8)) → \(value ? "조아용" : "시러용")", at: 0)
    }

    func addLog(_ text: String) {
        logs.insert(text, at: 0)
    }
}
