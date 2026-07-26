//
//  ParallelViewModel.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ParallelViewModel {
    private(set) var images: [LoadedImage] = []
    private(set) var isLoading = false
    private(set) var progress = "0 / 0"
    private(set) var elapsedSeconds: Double = 0
    private(set) var errorMessage: String?

    private let service: any ImageServing
    private let limit: Int

    init(service: any ImageServing = ImageService(), limit: Int = 10) {
        self.service = service
        self.limit = limit
    }

    func loadImages() async {
        guard !isLoading else { return }
        isLoading = true
        images = []
        errorMessage = nil
        progress = "0 / \(limit)"
        elapsedSeconds = 0

        let clock = ContinuousClock()
        let start = clock.now
        defer {
            elapsedSeconds = seconds(from: start.duration(to: clock.now))
            isLoading = false
        }

        do {
            let list = try await service.fetchImageList(page: 1, limit: limit)
            let service = self.service
            let total = limit

            try await withThrowingTaskGroup(of: LoadedImage.self) { group in
                for item in list {
                    group.addTask {
                        let data = try await service.fetchImageData(from: item.downloadURL)
                        return LoadedImage(image: item, data: data)
                    }
                }

                for try await loaded in group {
                    images.append(loaded)
                    progress = "\(images.count) / \(total)"
                    elapsedSeconds = seconds(from: start.duration(to: clock.now))
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func seconds(from duration: Duration) -> Double {
        let components = duration.components
        return Double(components.seconds) + (Double(components.attoseconds) / 1_000_000_000_000_000_000)
    }
}
