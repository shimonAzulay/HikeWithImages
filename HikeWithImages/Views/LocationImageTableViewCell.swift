//
//  LocationImageTableViewCell.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import UIKit

class LocationImageTableViewCell: UITableViewCell {
  static let identifier = "LocationImageTableViewCell"
  
  private lazy var locationImage: UIImageView = {
    let image = UIImageView()
    return image
  }()
  
  private var image: Image? {
    didSet {
      populate()
    }
  }
  
  func updateCell(with image: Image) {
    self.image = image
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
  }
}

private extension LocationImageTableViewCell {
  func populate() {
    guard let imageData = image?.imageData else { return }
    locationImage.image = UIImage(data: imageData)
  }
  
  func setupView() {
    contentView.addSubview(locationImage)
    locationImage.translatesAutoresizingMaskIntoConstraints = false
    locationImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    locationImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    locationImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    let locationImageWidthConstraint = locationImage.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9)
    locationImageWidthConstraint.priority = .defaultHigh
    locationImageWidthConstraint.isActive = true
    locationImage.heightAnchor.constraint(equalTo: locationImage.widthAnchor, multiplier: 0.5).isActive = true
  }
}
