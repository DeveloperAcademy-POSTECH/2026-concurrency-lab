//
//  ActorCacheView.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import SwiftUI

struct ActorCacheView: View {
    @State private var viewModel = ActorCacheViewModel()

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                statsBar
                Divider()
                imageGrid
            }
            .padding(.horizontal)
            .navigationTitle("Actor Cache")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        Task { await viewModel.reset() }
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Load") {
                        Task { await viewModel.loadImages() }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }

    private var statsBar: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                }
                Text("hits: \(viewModel.hitCount)")
                Text("miss: \(viewModel.missCount)")
                Text("dedup: \(viewModel.dedupedCount)")
                Spacer()
                Text(String(format: "%.2fs", viewModel.elapsedSeconds))
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline.monospacedDigit())

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
    ActorCacheView()
}
