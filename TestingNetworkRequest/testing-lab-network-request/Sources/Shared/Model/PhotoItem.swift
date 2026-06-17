/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

import Foundation

/**
 ```json
 [
   {
     "id": "0",
     "author": "Alejandro Escamilla",
     "width": 5000,
     "height": 3333,
     "url": "https://unsplash.com/photos/yC-Yzbqy7PY",
     "download_url": "https://picsum.photos/id/0/5000/3333"
   },
   ...
 ]
 ```
 */
public struct PhotoItem: Identifiable, Decodable, Equatable {
    public var id: String
    public var author: String
    public var width: Int
    public var height: Int
    public var urlString: String
    public var downloadURLString: String
    
    /// Read-only property
    public var url: URL? { URL(string: self.downloadURLString) }
    
    
    // MARK: - Decodable
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case width
        case height
        case url = "url"
        case downloadURL = "download_url"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.author = try container.decode(String.self, forKey: .author)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
        self.urlString = try container.decode(String.self, forKey: .url)
        self.downloadURLString = try container.decode(String.self, forKey: .downloadURL)
    }
    
    @_spi(Testing)
    public init(id: String, author: String, width: Int, height: Int, urlString: String, downloadURLString: String) {
        self.id = id
        self.author = author
        self.width = width
        self.height = height
        self.urlString = urlString
        self.downloadURLString = downloadURLString
    }
}

