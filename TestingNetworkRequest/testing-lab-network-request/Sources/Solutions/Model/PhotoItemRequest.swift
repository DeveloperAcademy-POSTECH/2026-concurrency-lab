/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import Foundation
import Shared

/**
 ## Networking Stack
 1. Prepare URLRequest
 2. Create URLSession Task
 3. Parse Response
 4. Update View
 
 ## URL Request
 Let's focus on "Prepare URLRequest" and "Parse Response"
 
 ## URL Protocol
 See the files in `APIClient/` path.
 */
struct PhotoItemRequest {
    func makeRequest(from params: PhotoItemParams) throws -> URLRequest {
        guard params.page >= 0, params.limit > 0 else {
            throw RequestError.invalidParameters
        }
        var components = URLComponents(string: "https://picsum.photos/v2/list")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(params.page)"),
            URLQueryItem(name: "limit", value: "\(params.limit)"),
        ]
        return URLRequest(url: components.url!)
    }

    func parseResponse(data: Data) throws -> [PhotoItem] {
        try JSONDecoder().decode([PhotoItem].self, from: data)
    }
}

// MARK: - APIRequest
extension PhotoItemRequest: APIRequest { }

