/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import Testing

import Foundation
import Shared
@testable import Solutions

/**
 ## What I really want to test at this layer of this suite?
 
 - My interaction with the `URLSession` APIs is correct
 - `URLSession` provides a high level API for apps to use to perform network requests.
 - The objects (e.g., URLSession data tests)
 - `Foundation` provides built-in protocols subclasses for common protocols like *HTTP*
 */


@Suite("Tests API Client")
struct APIClientTests {
    let apiClient: APIClient<PhotoItemRequest>
    
    init() {
        let request = PhotoItemRequest()
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        
        self.apiClient = APIClient(apiRequest: request, urlSession: urlSession)
    }
    
    /// Tests that `APIClient.loadData(from:)` loads data successfully.
    ///
    /// ### Steps
    /// 1. Declare testing data
    /// 2. Set up `MockURLProtocol.requestHandler` to return intentional testing data
    /// 3. Load data via `APIClient`
    /// 4. Compare loaded data to the expected data
    @Test
    func loadSuccessfully() async throws {
        // 1
        let inputParams = PhotoItemParams(page: 0, limit: 10)
        let mockJSONData = PhotoItem.sampleJSONData.data(using: .utf8)!
        
        // 2
        MockURLProtocol.requestHandler = { request in
            #expect(request.url?.query?.contains("page=0") == true)
            #expect(request.url?.query?.contains("limit=10") == true)
            return (HTTPURLResponse(), mockJSONData)
        }
        
        // 3
        let photoItems = try await apiClient.loadData(from: inputParams)
        
        // 4
        #expect(photoItems == PhotoItem.sampleData)
    }
}
