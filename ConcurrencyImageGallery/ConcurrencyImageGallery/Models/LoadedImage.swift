//
//  LoadedImage.swift
//  ConcurrencyImageGallery
//
//  Created by Youngmin Cho on 5/24/26.
//

import Foundation

struct LoadedImage: Identifiable, Sendable {
    let image: PicsumImage
    let data: Data

    var id: String { image.id }
}
