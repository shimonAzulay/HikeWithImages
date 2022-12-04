//
//  ImageDataCache.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation

actor ImageDataCache {
  private let cache = NSCache<NSLocation, NSData>()
  
  func getItem(forKey key: Location) -> Data? {
    guard let nsdata = cache.object(forKey: NSLocation(location: key)) else { return nil }
    return Data(referencing: nsdata)
  }

  func setItem(forKey key: Location, item: Data) {
    let nsitem = item as NSData
    let nskey = NSLocation(location: key)
    cache.setObject(nsitem, forKey: nskey)
  }
}

private class NSLocation: NSObject {
  let latitude: NSNumber
  let longitude: NSNumber
  
  init(location: Location) {
    self.latitude = location.latitude as NSNumber
    self.longitude = location.longitude as NSNumber
    super.init()
  }
}
