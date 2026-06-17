/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import Testing

import Foundation

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let handler = Self.requestHandler else {
            Issue.record("Received unexepected request with no handler set")
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        // ...
    }
}
