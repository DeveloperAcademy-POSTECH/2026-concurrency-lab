//
//  RoleSelectionView.swift
//  CorebluetoothConcurrency
//
//  Created by sun on 6/20/26.
//

import SwiftUI

struct RoleSelectionView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("BLE 역할 선택")
                    .font(.title)
                    .bold()

                NavigationLink {
                    CentralView()
                } label: {
                    Text("Central로 실행")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    PeripheralView()
                } label: {
                    Text("Peripheral로 실행")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("CoreBluetooth")
        }
    }
}
