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
  case badResponseData
  case badImageUrl
}

protocol ImageFetcher {
  func fetchImageUrl(atLocation location: Location) async throws -> URL
  func fetchImageData(atUrl url: URL) async throws -> Data
}

class FlickrImageFetcher: ImageFetcher {
  private let key = "2f76ed1b196da7089077878dc2e74b1d"
  private let base = "https://www.flickr.com/"
  private let service = "services/rest/"
  private let method = "method=flickr.photos.search"
  
  func fetchImageUrl(atLocation location: Location) async throws -> URL {
    guard let url = makeFlickrUrl(withLocation: location) else {
      throw ImageDataFetcherError.badLocationUrl
    }
    
    return try await Task.retrying {
      let (data, response) = try await URLSession.shared.data(from: url)
      guard let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode else {
        throw ImageDataFetcherError.badResponse
      }
      
      let decoder = JSONDecoder()
      let flickerResponse = try decoder.decode(FlickerResponse.self, from: data)
      
      guard let image = flickerResponse.photos.photo.first else {
        throw ImageDataFetcherError.badResponseData
      }
      
      guard let imageUrl = image.makeImageUrl else {
        throw ImageDataFetcherError.badImageUrl
      }
      
      return imageUrl
    }
    .value
  }
  
  func fetchImageData(atUrl url: URL) async throws -> Data {
    return try await Task.retrying {
      try Data(contentsOf: url)
    }
    .value
  }
}

private extension FlickrImageFetcher {
  func performFetchImageData(from url: URL) async throws -> Data {
    try Data(contentsOf: url)
  }
  
  func makeFlickrUrl(withLocation location: Location) -> URL? {
    let urlString = "\(base)\(service)?\(method)&api_key=\(key)&accuracy=\(location.accuracy)&lat=\(location.latitude)&lon=\(location.longitude)&per_page=1&page=1&format=json&nojsoncallback=1"
    
    return URL(string: urlString)
  }
}

private extension FlickrImage {
  var makeImageUrl: URL? {
    let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    return URL(string: urlString)
  }
}
