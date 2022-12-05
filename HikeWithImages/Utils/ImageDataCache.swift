//
//  ImageDataCache.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation

class ImageDataCache {
  private let cache = NSCache<NSString, NSData>()
  
  func getItem(forKey key: String) -> Data? {
    let nskey = key as NSString
    guard let nsdata = cache.object(forKey: nskey) else { return nil }
    return Data(referencing: nsdata)
  }

  func setItem(forKey key: String, item: Data) {
    let nsitem = item as NSData
    let nskey = key as NSString
    cache.setObject(nsitem, forKey: nskey)
  }
}
