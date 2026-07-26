//
//  Models.swift
//  ConcurrencyTesting
//
//  Created by Youngmin Cho on 6/20/26.
//

import Foundation

struct PhotoItem: Identifiable, Hashable, Sendable {
    let id: Int
    let url: URL
}

enum ImageServiceError: Error, Equatable {
    case invalidResponse
    case httpStatus(Int)
}
