/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import Testing

import Shared
@testable import Solutions

@Suite("Tests PhotoItemRequest")
struct PhotoItemRequestTests {
    let request = PhotoItemRequest()
    
    /// 1. Create `URLRequest` via `PhotoItemRequest`.
    /// 2. Compare the main components to the expected: `scheme`, `host`, `query`
    @Test(arguments: PhotoItemParams.successData)
    func makeRequest(params: PhotoItemParams) throws {
        // 1
        let urlRequest = try request.makeRequest(from: params)
        
        // 2
        #expect(urlRequest.url?.scheme == "https")
        #expect(urlRequest.url?.host == "picsum.photos")
        #expect(urlRequest.url?.query == "page=\(params.page)&limit=\(params.limit)")
    }
    
    /// 1. Prepare sample JSON data
    /// 2. Call `parseResponse(data:)` method in `PhotoItemRequest` to parse the JSON data
    /// 3. Compare the result to the expected data.
    @Test
    func parseResponse() throws {
        let jsonData = PhotoItem.sampleJSONData.data(using: .utf8)!
        let response = try request.parseResponse(data: jsonData)
        
        #expect(response == PhotoItem.sampleData)
        
    }
}
