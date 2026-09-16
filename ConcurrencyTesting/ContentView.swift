//
//  ContentView.swift
//  ConcurrencyTesting
//
//  Created by Youngmin Cho on 6/20/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SequentialView()
                .tabItem {
                    Label("Sequential", systemImage: "1.circle")
                }
        }
    }
}

#Preview {
    ContentView()
}
