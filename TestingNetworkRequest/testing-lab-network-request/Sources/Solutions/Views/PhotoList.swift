/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import SwiftUI

struct PhotoList: View {
    @State private var gallery = Gallery()
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(gallery.photoItems) {
                    AsyncImage(url: $0.url) { image in
                        image.resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 120, height: 160)
                    .clipped()
                }
            }
        }
        .task {
            await gallery.loadData(fromPageIndex: 10, atMost: 20)
        }
    }
}

#Preview {
    PhotoList()
        .preferredColorScheme(.dark)
        .background {
            Color.black
                .ignoresSafeArea()
        }
}
