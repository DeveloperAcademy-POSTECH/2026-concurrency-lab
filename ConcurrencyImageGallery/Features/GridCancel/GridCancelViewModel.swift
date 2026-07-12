//
//  GridCancelViewModel.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class GridCancelViewModel {
    private(set) var images: [PicsumImage] = []
    private(set) var errorMessage: String?
    private(set) var isLoading = false

    private let service: any ImageServing
    private let pageLimit: Int

    init(service: any ImageServing = ImageService(), pageLimit: Int = 30) {
        self.service = service
        self.pageLimit = pageLimit
    }

    func loadListIfNeeded() async {
        guard images.isEmpty, !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            async let page1 = service.fetchImageList(page: 1, limit: pageLimit)
            async let page2 = service.fetchImageList(page: 2, limit: pageLimit)
            let combined = try await page1 + page2
            images = combined
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
