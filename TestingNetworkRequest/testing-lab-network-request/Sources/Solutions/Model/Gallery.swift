/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import Shared
import SwiftUI

@MainActor @Observable
class Gallery {
    var photoItems: [PhotoItem] = []
    
    private let apiClient: APIClient<PhotoItemRequest> = .init(apiRequest: PhotoItemRequest())
    
    func loadData(fromPageIndex page: Int, atMost limit: Int) async {
        let params = PhotoItemParams(page: page, limit: limit)
        do {
            let photoItems = try await apiClient.loadData(from: params)
            self.photoItems = photoItems
        } catch {
            self.handleError(error)
            return
        }
    }
    
    private func handleError(_ error: Error) {
        logger.error("\(error.localizedDescription, privacy: .public)")
    }
}
