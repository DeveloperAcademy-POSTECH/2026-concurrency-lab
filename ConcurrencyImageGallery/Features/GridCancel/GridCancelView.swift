//
//  GridCancelView.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import SwiftUI

struct GridCancelView: View {
    @State private var viewModel = GridCancelViewModel()

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 4)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 4) {
                    ForEach(viewModel.images) { image in
                        GridCancelCell(image: image)
                    }
                }
                .padding(4)
            }
            .overlay {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .navigationTitle("Grid + Cancel")
            .task {
                await viewModel.loadListIfNeeded()
            }
        }
    }
}

struct GridCancelCell: View {
    let image: PicsumImage

    @State private var data: Data?
    @State private var didCancel = false

    private let service = ImageService()

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.gray.opacity(0.15))
                .aspectRatio(1, contentMode: .fit)

            if let data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if didCancel {
                Image(systemName: "xmark.circle")
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .task(id: image.id) {
            
            do {
                try await Task.sleep(for: .milliseconds(200))
                try Task.checkCancellation()
                let bytes = try await service.fetchImageData(from: image.downloadURL)
                try Task.checkCancellation()
                data = bytes
            } catch {
                didCancel = true
            }
        }
    }
}

#Preview {
    GridCancelView()
}
