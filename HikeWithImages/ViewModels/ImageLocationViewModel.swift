//
//  ImageLocationViewModel.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation
import Combine

class ImageLocationViewModel: ObservableObject {
  @Published var images = [Image]()
  @Published var started: Bool = false
  
  private var locationCancellable: AnyCancellable?
  private let imageDataFetcher: ImageDataFetcher
  private let locationProvider: LocationProvider
  
  init(imageDataFetcher: ImageDataFetcher,
       locationProvider: LocationProvider) {
    self.imageDataFetcher = imageDataFetcher
    self.locationProvider = locationProvider
  }
  
  func toggle() {
    started ? stop() : start()
  }
}

private extension ImageLocationViewModel {
  func start() {
    started = true
    locationCancellable = locationProvider.publisher
      .subscribe(on: DispatchQueue.global(qos: .background))
      .sink(receiveCompletion: {
        print($0)
      }, receiveValue: { [weak self] in
        self?.handleImageLocation(imageLocation: $0)
      })
    
  }
  
  func stop() {
    started = false
    locationCancellable?.cancel()
    locationCancellable = nil
  }
  
  func handleImageLocation(imageLocation: Location) {
    Task { @MainActor [weak self] in
      do {
        let imageData = try await imageDataFetcher.fetchImage(atLocation: imageLocation)
        self?.images.insert(Image(imageData: imageData), at: 0)
      } catch {
        print(error)
      }
    }
  }
}
