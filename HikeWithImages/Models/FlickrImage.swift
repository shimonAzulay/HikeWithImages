//
//  FlickrImage.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import Foundation

struct FlickerResponse: Decodable {
  let photos: FlickerImages
}

struct FlickerImages: Decodable {
  let photo: [FlickrImage]
}

struct FlickrImage: Decodable {
  let id: String
  let secret: String
  let server: String
  let farm: Int
}
