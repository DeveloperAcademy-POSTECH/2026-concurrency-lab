//
//  ImageService.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/19/26.
//

import Foundation

struct ImageService {
    func fetchImageList(page: Int, limit: Int) async throws ->  [PicsumImage] {
        var components = URLComponents(string: "https://picsum.photos/v2/list")!
        components.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit)),
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let images = try decoder.decode([PicsumImage].self, from: data)
        return images
    }

    func fetchImageData(from url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
