//
//  LocationProvider.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation
import Combine
import CoreLocation

enum LocationProviderStatus {
  case permissionGranted
  case location(Location)
  case noPermission
  case failedToFetchLocation(Error)
}

protocol LocationProvider {
  var publisher: AnyPublisher<LocationProviderStatus, Never> { get }
  var distanceFilter: Int { get set }
  var accuracy: Int { get set }
  var locations: [Location] { get }
  func start()
  func stop()
}

class AppLocationProvider: NSObject, LocationProvider {
  private let locationManager = CLLocationManager()
  private let locationSubject = PassthroughSubject<LocationProviderStatus, Never>()
  
  var publisher: AnyPublisher<LocationProviderStatus, Never> {
    locationSubject.eraseToAnyPublisher()
  }
  
  var distanceFilter: Int = 100 {
    didSet {
      guard distanceFilter > 0 else {
        locationManager.distanceFilter = kCLDistanceFilterNone
        return
      }
      
      print("Distance filter changed to: \(distanceFilter)")
      locationManager.distanceFilter = CLLocationDistance(distanceFilter)
    }
  }
  
  var accuracy: Int = 16 {
    didSet {
      print("Accuracy changed to: \(accuracy)")
    }
  }
  
  private(set) var locations = [Location]()
  
  override init() {
    super.init()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.activityType = .otherNavigation
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.showsBackgroundLocationIndicator = true
    locationManager.distanceFilter = 100
  }

  func start() {
    print("Start location provider")
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.startUpdating()
    }
  }
  
  func stop() {
    print("Stop location provider")
    locationManager.stopUpdatingLocation()
    locationManager.delegate = nil
  }
  
  private func startUpdating() {
    guard locationManager.isPermissionDenied == false else {
      locationSubject.send(.noPermission)
      return
    }
    
    locationManager.delegate = self
    guard locationManager.isPermissionNotDetermined == false else {
      locationManager.requestAlwaysAuthorization()
      return
    }
    
    locationManager.startUpdatingLocation()
  }
}

private extension CLLocationManager {
  var isPermissionDenied: Bool {
    let status = authorizationStatus
    return status == .denied || status == .restricted
  }
  
  var isPermissionNotDetermined: Bool {
    authorizationStatus == .notDetermined
  }
}

extension AppLocationProvider: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard manager.isPermissionDenied == false else {
      locationSubject.send(.noPermission)
      return
    }
    
    guard manager.isPermissionNotDetermined == false else { return }
    
    locationSubject.send(.permissionGranted)
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Failed to fetch location: \(error)")
    locationSubject.send(.failedToFetchLocation(error))
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let lastLocation = locations.last else {
      return
    }
    
    guard lastLocation.horizontalAccuracy < Double(accuracy) else {
      print("Received location with an accuracy: \(lastLocation.horizontalAccuracy)")
      return
    }
    
    let location = Location(latitude: lastLocation.coordinate.latitude,
                            longitude: lastLocation.coordinate.longitude,
                            accuracy: lastLocation.horizontalAccuracy)
    print("Received location at: \(location)")
    self.locations.append(location)
    locationSubject.send(.location(location))
  }
}
