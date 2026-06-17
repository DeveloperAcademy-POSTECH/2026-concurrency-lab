//
//  ContentView.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/19/26.
//

import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Sequential", systemImage: "arrow.down") {
                SequentialView()
            }

            Tab("Parallel", systemImage: "square.grid.2x2") {
                ParallelView()
            }

            Tab("Grid+Cancel", systemImage: "rectangle.grid.3x2") {
                GridCancelView()
            }

            Tab("Actor", systemImage: "tray.full") {
                ActorCacheView()
            }
        }
    }
}

#Preview {
    RootTabView()
}
