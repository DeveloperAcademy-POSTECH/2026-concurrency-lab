//
//  ParallelView.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import SwiftUI

struct ParallelView: View {
    @State private var viewModel = ParallelViewModel()

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                statusBar
                Divider()
                imageGrid
            }
            .padding(.horizontal)
            .navigationTitle("Parallel")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Load") {
                        Task { await viewModel.loadImages() }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }

    private var statusBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                }
                Text("Progress: \(viewModel.progress)")
                    .font(.subheadline)
                Spacer()
                Text(String(format: "%.2fs", viewModel.elapsedSeconds))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var imageGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.images) { loaded in
                    if let uiImage = UIImage(data: loaded.data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }
}

#Preview {
    ParallelView()
}
