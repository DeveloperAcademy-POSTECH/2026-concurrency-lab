//
//  CentralBLEModel.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import Foundation
import Observation
import CoreBluetooth

@Observable
final class CentralBLEModel {
    var status: String = "Idle"
    var logs: [String] = []
    var discovered: [DiscoveredPeripheral] = []

    func addLog(_ text: String) {
        logs.insert(text, at: 0)
    }
}

struct DiscoveredPeripheral: Identifiable {
    let id: UUID
    let name: String
    let rssi: Int
    let peripheral: CBPeripheral
}
