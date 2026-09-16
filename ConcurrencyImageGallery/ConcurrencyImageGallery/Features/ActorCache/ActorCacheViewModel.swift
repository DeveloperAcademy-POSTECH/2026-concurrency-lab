//
//  ActorCacheViewModel.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class ActorCacheViewModel {
    private(set) var images: [LoadedImage] = []
    private(set) var isLoading = false
    private(set) var hitCount = 0
    private(set) var missCount = 0
    private(set) var dedupedCount = 0
    private(set) var elapsedSeconds: Double = 0
    private(set) var errorMessage: String?

    private let service: any ImageServing
    private let cache: ImageCache
    private let limit: Int
    private let duplicateRequests: Int

    init(
        service: any ImageServing = ImageService(),
        cache: ImageCache? = nil,
        limit: Int = 10,
        duplicateRequests: Int = 3
    ) {
        self.service = service
        self.cache = cache ?? ImageCache(fetchImageData: { url in
            try await service.fetchImageData(from: url)
        })
        self.limit = limit
        self.duplicateRequests = duplicateRequests
    }

    func loadImages() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        images = []

        let start = Date()
        defer {
            elapsedSeconds = Date().timeIntervalSince(start)
            isLoading = false
        }

        do {
            let list = try await service.fetchImageList(page: 1, limit: limit)
            let cache = self.cache
            let duplicates = duplicateRequests

            let loaded = try await withThrowingTaskGroup(
                of: (PicsumImage, Data).self
            ) { group in
                for item in list {
                    for _ in 0..<duplicates {
                        group.addTask {
                            let data = try await cache.image(for: item.downloadURL)
                            return (item, data)
                        }
                    }
                }

                var seen: Set<String> = []
                var results: [LoadedImage] = []
                for try await (item, data) in group {
                    if seen.insert(item.id).inserted {
                        results.append(LoadedImage(image: item, data: data))
                    }
                }
                return results
            }

            images = loaded
            hitCount = await cache.hitCount
            missCount = await cache.missCount
            dedupedCount = await cache.dedupedCount
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func reset() async {
        await cache.reset()
        images = []
        hitCount = 0
        missCount = 0
        dedupedCount = 0
        elapsedSeconds = 0
        errorMessage = nil
    }
}
