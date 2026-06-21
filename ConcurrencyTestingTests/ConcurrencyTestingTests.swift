//
//  ConcurrencyTestingTests.swift
//  ConcurrencyTestingTests
//
//  Created by Youngmin Cho on 6/20/26.
//

import Foundation
import Testing
@testable import ConcurrencyTesting

@MainActor
struct ConcurrencyTestingTests {
    @Test
    func sequentialLoadPhotos_addsFivePhotos() async {
        let service = ImageService { request in
            let response = HTTPURLResponse(
                url: try #require(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!

            return (Data([1, 2, 3]), response)
        }

        let viewModel = SequentialViewModel(imageService: service)

        await viewModel.loadPhotos()

        #expect(viewModel.photos.count == 5)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
}
