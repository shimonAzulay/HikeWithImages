//
//  ImageDataFetcher.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation

enum ImageDataFetcherError: Error {
  case badLocationUrl
  case badResponse
  case badImageUrl
}

protocol ImageDataFetcher {
  func fetchImage(atLocation location: Location) async throws -> Data
}

class FlickerImageDataFetcher: ImageDataFetcher {
  private let key = "2f76ed1b196da7089077878dc2e74b1d"
  private let base = "https://www.flickr.com/"
  private let service = "services/rest/"
  private let method = "method=flickr.photos.search"
  private let cache = ImageDataCache()
  
  func fetchImage(atLocation location: Location) async throws -> Data {
    if let imageData = await cache.getItem(forKey: location) {
      return imageData
    }
    
    guard let url = makeFlickrUrl(withLocation: location) else {
      throw ImageDataFetcherError.badLocationUrl
    }
 
    print(url)
    let (data, _) = try await URLSession.shared.data(from: url)
    let decoder = JSONDecoder()
    let flickerResponse = try decoder.decode(FlickerResponse.self, from: data)
    
    print(flickerResponse)
    guard let image = flickerResponse.photos.photo.first else {
      throw ImageDataFetcherError.badResponse
    }
    
    guard let imageUrl = image.makeImageUrl else {
      throw ImageDataFetcherError.badImageUrl
    }
    
    let imageData = try Data(contentsOf: imageUrl)
    
    await cache.setItem(forKey: location, item: imageData)
    return imageData
  }
}

private extension FlickerImageDataFetcher {
  func makeFlickrUrl(withLocation location: Location) -> URL? {
    let urlString = "\(base)\(service)?\(method)&api_key=\(key)&lat=\(location.latitude)&lon=\(location.longitude)&per_page=1&page=1&format=json&nojsoncallback=1"
    
    return URL(string: urlString)
  }
}

private extension FlickrImage {
  var makeImageUrl: URL? {
    let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    return URL(string: urlString)
  }
}
