//
//  LocationImageTableViewCell.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import UIKit

class ImageLocationTableViewCell: UITableViewCell {
  static let identifier = "ImageLocationTableViewCell"
  
  private lazy var locationImage: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleToFill
    return image
  }()
  
  private var imageFetcher: ImageFetcher?
  private var imageData: Data? {
    didSet {
      populate()
    }
  }
  
  func updateCell(WithImageUrl url: URL, imageFetcher: ImageFetcher) {
    self.imageFetcher = imageFetcher
    guard let imageData = imageFetcher.cache.getItem(forKey: url.absoluteString) else {
      Task { @MainActor [weak self] in
        do {
          guard let imageData = try await self?.imageFetcher?.fetchImageData(atUrl: url) else { return }
          self?.imageFetcher?.cache.setItem(forKey: url.absoluteString, item: imageData)
          self?.imageData = imageData
        } catch {
          print(error)
        }
      }
      
      return
    }
    
    self.imageData = imageData
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupView()
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    locationImage.image = nil
    imageData = nil
  }
}

private extension ImageLocationTableViewCell {
  func populate() {
    guard let imageData = imageData else { return }
    locationImage.image = UIImage(data: imageData)
  }
  
  func setupView() {
    backgroundColor = .clear
    contentView.backgroundColor = .clear
    selectionStyle = .none
    contentView.addSubview(locationImage)
    locationImage.translatesAutoresizingMaskIntoConstraints = false
    locationImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
    locationImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    locationImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    locationImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.95).isActive = true
    locationImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
  }
}
