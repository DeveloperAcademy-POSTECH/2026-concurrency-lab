//
//  ContentView.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/19/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Sequential", systemImage: "arrow.down") {
                EmptyView()
            }
            
            Tab("Parallel", systemImage: "square.grid.2x2") {
                EmptyView()
            }
            
            Tab("Actor", systemImage: "tray.full") {
                EmptyView()
            }
        }
    }
}

#Preview {
    ContentView()
}
