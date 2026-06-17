/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

@testable import Solutions

extension PhotoItemParams {
    static let successData: [PhotoItemParams] = [
        PhotoItemParams(page: 0, limit: 10),
        PhotoItemParams(page: 1, limit: 10),
        PhotoItemParams(page: 2, limit: 20),
    ]
    
    static let failureData: [PhotoItemParams] = [
        PhotoItemParams(page: -1, limit: 10),
        PhotoItemParams(page: 0, limit: -10),
    ]
}
