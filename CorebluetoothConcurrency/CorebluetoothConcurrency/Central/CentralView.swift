//
//  CentralView.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/18/26.
//

import SwiftUI

struct CentralView: View {
    @State private var model = CentralBLEModel()
    @State private var manager = CentralBLEManager()

    var body: some View {
        VStack(spacing: 20) {

            Text("Central iPhone")
                .font(.largeTitle)
                .bold()

            Text(model.status)
                .font(.headline)

            HStack {
                Button("Scan") {
                    manager.scan()
                }
                .buttonStyle(.bordered)

                Button("Stop Scan") {
                    manager.stopScan()
                }
                .buttonStyle(.bordered)

                Button("Disconnect") {
                    manager.disconnect()
                }
                .buttonStyle(.bordered)
            }

            HStack {
                Button("조아용") {
                    manager.send(.good)
                }
                .buttonStyle(.bordered)

                Button("시러용") {
                    manager.send(.bad)
                }
                .buttonStyle(.bordered)
            }

            Divider()

            GroupBox("발견된 iPhone") {
                ScrollView {
                    LazyVStack(spacing: 8) {

                        if model.discovered.isEmpty {
                            Text("발견된 iPhone 없음")
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        }

                        ForEach(model.discovered) { item in
                            HStack {
                                Text(item.name)
                                    .font(.headline)

                                Spacer()

                                Text(String(item.id.uuidString.prefix(8)))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .monospaced()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                manager.connect(to: item)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .frame(height: 120)
            }

            List(model.logs, id: \.self) { log in
                Text(log)
                    .font(.caption)
            }
        }
        .padding()
        .task {
            for await event in manager.events {
                await MainActor.run {
                    switch event {
                    case .bluetoothStateChanged(let state, let log):
                        model.status = state
                        model.addLog(log)
                        
                    case .discovered(let item, let log):
                        model.discovered.append(item)
                        model.addLog(log)
                        
                    case .discoveredCleared(let log):
                        model.discovered.removeAll()
                        model.addLog(log)
                        
                    case .statusChanged(let status, let log):
                        model.status = status
                        model.addLog(log)
                        
                    case .log(let message):
                        model.addLog(message)
                    }
                }
            }
        }
    }
}
