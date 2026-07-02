//
//  PeripheralView.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import SwiftUI

struct PeripheralView: View {
    @State private var model = PeripheralBLEModel()
    @State private var manager = PeripheralBLEManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Peripheral iPhone")
                .font(.largeTitle)
                .bold()

            Text(model.bluetoothStateText)
                .font(.headline)

            Text(model.isAdvertising ? "Advertising 중" : "Advertising 안 함")
                .foregroundStyle(model.isAdvertising ? .green : .secondary)

            HStack {
                Button("Start Advertising") {
                    manager.startAdvertising()
                }
                .buttonStyle(.bordered)

                Button("Stop") {
                    manager.stopAdvertising()
                }
                .buttonStyle(.bordered)
            }

            Divider()

            List {
                Section("Answers") {
                    ForEach(Array(model.answers.keys), id: \.self) { id in
                        if let value = model.answers[id] {
                            HStack {
                                Text(id.uuidString.prefix(8))
                                Spacer()
                                Text(value ? "조아용" : "시러용")
                            }
                        }
                    }
                }

                Section("Logs") {
                    ForEach(model.logs, id: \.self) { log in
                        Text(log)
                            .font(.caption)
                    }
                }
            }
        }
        .padding()
        .task {
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
        }
    }
}
