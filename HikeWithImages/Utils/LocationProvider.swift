//
//  File.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation
import Combine
import CoreLocation

protocol LocationProvider {
  var publisher: AnyPublisher<Location, Never> { get }
}

class AppLocationProvider: NSObject, LocationProvider {
  private let manager = CLLocationManager()
  private var timer: Timer?
  private let locationSubject = PassthroughSubject<Location, Never>()
  
  override init() {
    super.init()
  }
  
  var publisher: AnyPublisher<Location, Never> {
    DispatchQueue.global().asyncAfter(deadline: .now() + 3.0) { [weak self] in
      print("Timer fired!")
      self?.locationSubject.send(Location(latitude: 53.2734,
                                          longitude: -7.77832031))
    }
    
    return locationSubject.eraseToAnyPublisher()
  }
}

extension AppLocationProvider: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways {
      if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        if CLLocationManager.isRangingAvailable() {
          print("authorizedAlways")
        }
      }
    }
  }
}
