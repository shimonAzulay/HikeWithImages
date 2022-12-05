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
    case image(URL)
    case noPermission
    case failed(FailureReason)
    
    enum FailureReason {
      case locationError(Error)
      case imageFetchError(Error)
    }
  }
  
  @Published var state: State = .stopped {
    didSet {
      switch state {
      case .stopped:
        stop()
      case .started:
        start()
      case .image:
        break
      case .noPermission, .failed:
        state = .stopped
      }
    }
  }
  
  let imageDataCache = ImageDataCache()
  let imageFetcher: ImageFetcher
  let locationProvider: LocationProvider
  
  init(imageFetcher: ImageFetcher,
       locationProvider: LocationProvider) {
    self.imageFetcher = imageFetcher
    self.locationProvider = locationProvider
  }
  
  func toggleStartStop() {
    switch state {
    case .started, .image:
      state = .stopped
    case .stopped:
      state = .started
    case .failed, .noPermission:
      break
    }
  }
}

private extension ImagesLocationsViewModel {
  func start() {
    locationCancellable = locationProvider.publisher
      .sink{ [weak self] in
        self?.handleLocationProviderStatus($0)
      }
    
    locationProvider.start()
  }
  
  func stop() {
    locationProvider.stop()
  }
  
  func handleLocationProviderStatus(_ status: LocationProviderStatus) {
    print("New status: \(status)")
    switch status {
    case .noPermission:
      state = .noPermission
    case .failedToFetchLocation(let error):
      print("Location error: \(error.localizedDescription)")
      state = .failed(.locationError(error))
    case .location(let location):
      fetchImage(atLocation: location)
    case .permissionGranted:
      if case .started = state {
        locationProvider.start()
      }
    }
  }
  
  func fetchImage(atLocation location: Location) {
    Task { @MainActor [weak self] in
      do {
        let imageUrl = try await imageFetcher.fetchImageUrl(atLocation: location)
        self?.state = .image(imageUrl)
      } catch {
        print("Failed to fetch image url by location: \(location) error: \(error)")
        self?.state = .failed(.imageFetchError(error))
      }
    }
  }
}
