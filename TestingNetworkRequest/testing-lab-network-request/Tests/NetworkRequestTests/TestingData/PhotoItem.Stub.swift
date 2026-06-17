/*
 This source file is part of the TestingLab open source project
 
 Copyright (c) 2026 Apple Developer Academy @ POSTECH and the Testing Lab project authors.
 Licensed under MIT License.
 
 See the LICENSE.txt file for license information.
 See CONTRIBUTORS.txt for the list of Testing Lab project authors
*/

@_spi(Testing) import Shared

extension PhotoItem {
    static let sampleJSONData: String = """
        [{"id":"0","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/yC-Yzbqy7PY","download_url":"https://picsum.photos/id/0/5000/3333"},{"id":"1","author":"Alejandro Escamilla","width":5000,"height":3333,"url":"https://unsplash.com/photos/LNRyGwIJr5c","download_url":"https://picsum.photos/id/1/5000/3333"}]
        """
    
    nonisolated(unsafe) static let sampleData: [PhotoItem] = [
        PhotoItem(
            id: "0",
            author: "Alejandro Escamilla",
            width: 5000,
            height: 3333,
            urlString: "https://unsplash.com/photos/yC-Yzbqy7PY",
            downloadURLString: "https://picsum.photos/id/0/5000/3333"
        ),
        PhotoItem(
            id: "1",
            author: "Alejandro Escamilla",
            width: 5000,
            height: 3333,
            urlString: "https://unsplash.com/photos/LNRyGwIJr5c",
            downloadURLString: "https://picsum.photos/id/1/5000/3333"
        ),
    ]
}
