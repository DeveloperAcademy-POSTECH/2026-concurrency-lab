//
//  ImageCache.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import Foundation

actor ImageCache {
    private var storage: [URL: Data] = [:]
    private var inFlight: [URL: Task<Data, Error>] = [:]

    private(set) var hitCount = 0
    private(set) var missCount = 0
    private(set) var dedupedCount = 0

    private let fetchImageData: @Sendable (URL) async throws -> Data

    init(fetchImageData: @escaping @Sendable (URL) async throws -> Data = { url in
        try await ImageService().fetchImageData(from: url)
    }) {
        self.fetchImageData = fetchImageData
    }

    func image(for url: URL) async throws -> Data {
        if let cached = storage[url] {
            hitCount += 1
            return cached
        }

        if let existing = inFlight[url] {
            dedupedCount += 1
            return try await existing.value
        }

        missCount += 1
        let task = Task {
            try await fetchImageData(url)
        }
        inFlight[url] = task

        do {
            let data = try await task.value
            storage[url] = data
            inFlight[url] = nil
            return data
        } catch {
            inFlight[url] = nil
            throw error
        }
    }

    func reset() {
        storage.removeAll()
        inFlight.removeAll()
        hitCount = 0
        missCount = 0
        dedupedCount = 0
    }
}
