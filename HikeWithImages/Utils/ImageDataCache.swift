//
//  ImageDataCache.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation

actor ImageDataCache {
  private var cache = [Location: Data]()
  
  func getItem(forKey key: Location) -> Data? {
    cache[key]
  }

  func setItem(forKey key: Location, item: Data) {
    cache[key] = item
  }
}
