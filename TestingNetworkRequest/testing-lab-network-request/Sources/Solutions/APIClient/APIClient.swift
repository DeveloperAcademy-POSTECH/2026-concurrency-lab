/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import Foundation

/// - NOTE: See `MockURLProtocol` and `APIClientTests`
final class APIClient<T: APIRequest>: Sendable {
    let apiRequest: T
    let urlSession: URLSession
    
    init(apiRequest: T, urlSession: URLSession = .shared) {
        self.apiRequest = apiRequest
        self.urlSession = urlSession
    }
    
    func loadData(from requestParams: T.RequestParams) async throws -> T.ResponseData {
        let urlRequest = try apiRequest.makeRequest(from: requestParams)
        let (data, _) = try await urlSession.data(for: urlRequest)
        let parsedResponse = try self.apiRequest.parseResponse(data: data)
        return parsedResponse
    }
}
