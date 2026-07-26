import Foundation
import Testing
@testable import ConcurrencyImageGallery

private struct MockImageService: ImageServing {
    let imageListResult: Result<[PicsumImage], Error>
    let imageDataResult: Result<Data, Error>

    func fetchImageList(page: Int, limit: Int) async throws -> [PicsumImage] {
        try imageListResult.get()
    }

    func fetchImageData(from url: URL) async throws -> Data {
        try imageDataResult.get()
    }
}

private struct DummyError: Error {}

struct ConcurrencyImageGalleryTests {
    @Test
    @MainActor
    func sequentialViewModelLoadsImagesInOrder() async throws {
        let images = [
            PicsumImage(
                id: "1",
                author: "Author 1",
                width: 100,
                height: 100,
                downloadURL: try #require(URL(string: "https://example.com/1.jpg"))
            ),
            PicsumImage(
                id: "2",
                author: "Author 2",
                width: 200,
                height: 200,
                downloadURL: try #require(URL(string: "https://example.com/2.jpg"))
            ),
        ]

        let service = MockImageService(
            imageListResult: .success(images),
            imageDataResult: .success(Data([1, 2, 3]))
        )

        let viewModel = SequentialViewModel(service: service, limit: 2)

        await viewModel.loadImages()

        #expect(viewModel.images.count == 2)
        #expect(viewModel.progress == "2 / 2")
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.images[0].id == "1")
        #expect(viewModel.images[1].id == "2")
    }

    @Test
    @MainActor
    func sequentialViewModelStoresErrorWhenListLoadingFails() async {
        let service = MockImageService(
            imageListResult: .failure(DummyError()),
            imageDataResult: .success(Data())
        )

        let viewModel = SequentialViewModel(service: service, limit: 2)

        await viewModel.loadImages()

        #expect(viewModel.images.isEmpty)
        #expect(viewModel.errorMessage != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test
    func imageCacheResetClearsState() async throws {
        let url = try #require(URL(string: "https://example.com/image.jpg"))

        let cache = ImageCache { _ in
            Data([1, 2, 3])
        }

        _ = try await cache.image(for: url)
        _ = try await cache.image(for: url)

        #expect(await cache.missCount == 1)
        #expect(await cache.hitCount == 1)

        await cache.reset()

        #expect(await cache.missCount == 0)
        #expect(await cache.hitCount == 0)
        #expect(await cache.dedupedCount == 0)
    }

    @Test
    func imageCacheDeduplicatesInFlightRequests() async throws {
        let url = try #require(URL(string: "https://example.com/image.jpg"))
        let expectedData = Data([9, 9, 9])

        actor Counter {
            var value = 0

            func increment() {
                value += 1
            }

            func currentValue() -> Int {
                value
            }
        }

        let counter = Counter()

        let cache = ImageCache { _ in
            await counter.increment()
            try await Task.sleep(for: .milliseconds(100))
            return expectedData
        }

        async let first = cache.image(for: url)
        async let second = cache.image(for: url)
        async let third = cache.image(for: url)

        let results = try await [first, second, third]

        #expect(results[0] == expectedData)
        #expect(results[1] == expectedData)
        #expect(results[2] == expectedData)
        #expect(await counter.currentValue() == 1)
        #expect(await cache.missCount == 1)
        #expect(await cache.dedupedCount == 2)
    }
}
