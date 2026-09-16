//
//  SequentialViewModel.swift
//  ConcurrencyTesting
//
//  Created by Youngmin Cho on 6/21/26.
//

import Foundation
import Observation

@Observable
final class SequentialViewModel {
    var photos: [SequentialPhoto] = []
    var isLoading = false
    var errorMessage: String?
    
    private let imageService: ImageService
    
    init(imageService: ImageService = ImageService()) {
        self.imageService = imageService
    }
    
    func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        photos = []
        
        let items = imageService.makePhotoItems(count: 5)
        do {
            for item in items {
                let data = try await imageService.fetchImageData(from: item.url)
                photos.append(SequentialPhoto(id: item.id, data: data))
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
