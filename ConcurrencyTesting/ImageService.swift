//
//  ImageService.swift
//  ConcurrencyTesting
//
//  Created by Youngmin Cho on 6/20/26.
//

import Foundation

typealias DataLoader = @Sendable (URLRequest) async throws -> (Data, URLResponse)

struct ImageService: Sendable {
    private let dataLoader: DataLoader
    
    init(dataLoader: @escaping DataLoader = { requset in
        try await URLSession.shared.data(for: requset)
    }) {
        self.dataLoader = dataLoader
    }
    
    func makePhotoItems(count: Int, size: Int = 200) -> [PhotoItem] {
        (1...count).compactMap { id in
            let urlString = "https://picsum.photos/id/\(id)/\(size)/\(size)"
            guard let url = URL(string: urlString) else {
                return nil
            }
            return PhotoItem(id: id, url: url)
        }
    }
    
    func fetchImageData(from url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await dataLoader(request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ImageServiceError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ImageServiceError.httpStatus(httpResponse.statusCode)
        }
        
        return data
    }
}
