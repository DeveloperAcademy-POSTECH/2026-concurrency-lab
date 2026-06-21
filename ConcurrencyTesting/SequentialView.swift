//
//  SequentialView.swift
//  ConcurrencyTesting
//
//  Created by Youngmin Cho on 6/21/26.
//

import SwiftUI

struct SequentialView: View {
    @State private var viewModel = SequentialViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("다운로드된 개수: \(viewModel.photos.count)")
            }
            
            if viewModel.isLoading {
                ProgressView("다운로드 중...")
            }
            
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            
            Button("다운 시작") {
                Task {
                    await viewModel.loadPhotos()
                }
            }
            
            List(viewModel.photos) { photo in
                Text("Photo \(photo.id) - \(photo.data.count) bytes")
            }
        }
        .padding()
        .navigationTitle("Sequential")
    }
}

#Preview {
    SequentialView()
}
