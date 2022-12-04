//
//  ImageLocationViewModel.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation
import Combine

class ImagesLocationsViewModel: ObservableObject {
  private var locationCancellable: AnyCancellable?
  
  enum State {
    case stopped
    case started
    case image(Image)
    case noPermission
    case failed(FailureReason)
    
    enum FailureReason {
      case locationError(Error)
      case imageFetchError(Error)
    }
  }
  
  @Published var state: State = .stopped
  
  let imageDataFetcher: ImageDataFetcher
  let locationProvider: LocationProvider
  
  init(imageDataFetcher: ImageDataFetcher,
       locationProvider: LocationProvider) {
    self.imageDataFetcher = imageDataFetcher
    self.locationProvider = locationProvider
  }
  
  func toggleStartStop() {
    switch state {
    case .started, .image:
      stop()
    case .stopped:
      start()
    case .failed, .noPermission:
      break
    }
  }
}

private extension ImagesLocationsViewModel {
  func start() {
    state = .started
    locationCancellable = locationProvider.publisher
      .sink{ [weak self] in
        self?.handleLocationProviderStatus($0)
      }
    
    locationProvider.start()
  }
  
  func stop() {
    state = .stopped
    locationProvider.stop()
  }
  
  func handleLocationProviderStatus(_ status: LocationProviderStatus) {
    switch status {
    case .noPermission:
      state = .noPermission
    case .failedToFetchLocation(let error):
      state = .failed(.locationError(error))
    case .location(let location):
      fetchImage(atLocation: location)
    }
  }
  
  func fetchImage(atLocation location: Location) {
    Task { @MainActor [weak self] in
      do {
        let imageData = try await imageDataFetcher.fetchImage(atLocation: location)
        self?.state = .image(Image(imageData: imageData))
      } catch {
        self?.state = .failed(.imageFetchError(error))
      }
    }
  }
}
