//
//  PicsumImage.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/19/26.
//

import Foundation

struct PicsumImage: Decodable, Identifiable, Sendable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let downloadURL: URL

    private enum CodingKeys: String, CodingKey {
        case id, author, width, height
        case downloadURL = "download_url"
    }
}
