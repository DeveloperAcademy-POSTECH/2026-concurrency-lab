//
//  SequentialPhoto.swift
//  ConcurrencyTesting
//
//  Created by Youngmin Cho on 6/21/26.
//

import Foundation

struct SequentialPhoto: Identifiable, Sendable {
    let id: Int
    let data: Data
}
