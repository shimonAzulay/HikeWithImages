//
//  ImageLocationViewModel.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 05/12/2022.
//

import Foundation

class ImageLocationViewModel: ObservableObject {
  @Published var imageData: Data?
  
  let imageDataCache: ImageDataCache
  let imageFetcher: ImageFetcher
  let imageUrl: URL
  
  init(imageFetcher: ImageFetcher,
       imageDataCache: ImageDataCache,
       imageUrl: URL) {
    self.imageFetcher = imageFetcher
    self.imageDataCache = imageDataCache
    self.imageUrl = imageUrl
  }
  
  func fetchImage() {
    if let imageData = imageDataCache.getItem(forKey: imageUrl.absoluteString) {
      self.imageData = imageData
      return
    }
    
    Task { @MainActor [weak self] in
      do {
        guard let imageData = try await self?.imageFetcher.fetchImageData(atUrl: imageUrl) else { return }
        self?.imageDataCache.setItem(forKey: imageUrl.absoluteString, item: imageData)
        self?.imageData = imageData
      } catch {
        print(error)
      }
    }
  }
}
