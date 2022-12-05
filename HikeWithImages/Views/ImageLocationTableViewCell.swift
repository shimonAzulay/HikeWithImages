//
//  LocationImageTableViewCell.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import UIKit
import Combine

class ImageLocationTableViewCell: UITableViewCell {
  static let identifier = "ImageLocationTableViewCell"
  
  private lazy var locationImage: UIImageView = {
    let image = UIImageView()
    image.contentMode = .scaleToFill
    return image
  }()
  
  private var imageFetcherCancellable: AnyCancellable?
  private var imageLocationViewModel: ImageLocationViewModel?
  
  func updateCell(viewModel: ImageLocationViewModel) {
    imageLocationViewModel = viewModel
    imageFetcherCancellable = imageLocationViewModel?.$imageData
      .sink { [weak self] imageData in
        guard let imageData else { return }
        self?.populate(imageData)
      }
    
    imageLocationViewModel?.fetchImage()
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
    imageFetcherCancellable?.cancel()
    imageFetcherCancellable = nil
  }
}

private extension ImageLocationTableViewCell {
  func populate(_ imageData: Data) {
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
