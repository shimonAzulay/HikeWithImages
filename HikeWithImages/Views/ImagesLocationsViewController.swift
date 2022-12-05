//
//  ViewController.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import UIKit
import Combine

class ImagesLocationsViewController: UIViewController {
  private lazy var statuslabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.font = .systemFont(ofSize: 20)
    label.textColor = .black
    return label
  }()
  
  private lazy var imagesTableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = .singleLine
    tableView.allowsSelection = false
    tableView.backgroundColor = .white
    return tableView
  }()
  
  private lazy var startStopHikeButton: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(startStopHikeTapped))
    return barButtonItem
  }()
  
  private lazy var debugButton: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem(title: "Debug", style: .plain, target: self, action: #selector(debugTapped))
    return barButtonItem
  }()
  
  private var images = [URL]() {
    didSet {
      statuslabel.isHidden = !images.isEmpty
      imagesTableView.reloadData()
    }
  }
  
  private var cancellable: AnyCancellable?
  private let viewModel: ImagesLocationsViewModel
  
  init(viewModel: ImagesLocationsViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    cancellable = viewModel.$state
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        switch state {
        case .started:
          self?.startStopHikeButton.title = "Stop"
          self?.statuslabel.text = "Waiting for a location..."
        case .stopped:
          self?.startStopHikeButton.title = "Start"
          self?.statuslabel.text = "Press Start to show images based on your location"
        case .image(let imageData):
          self?.images.insert(imageData, at: 0)
        case .noPermission, .failed:
          self?.showAlert(withTitle: state.alertTitle,
                          message: state.alertMessage)
        }
      }
    
    setupView()
    setupTableView()
    setupLabel()
  }
  
  @objc func startStopHikeTapped() {
    viewModel.toggleStartStop()
  }
  
  @objc func debugTapped() {
    let vc = DebugViewController()
    vc.locationProvider = viewModel.locationProvider
    present(vc, animated: true)
  }
}

private extension ImagesLocationsViewController {
  func setupView() {
    navigationItem.rightBarButtonItem  = startStopHikeButton
#if DEBUG
    navigationItem.leftBarButtonItem = debugButton
#endif
    view.backgroundColor = .white
  }
  
  func setupTableView() {
    imagesTableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imagesTableView)
    imagesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    imagesTableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    imagesTableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
    imagesTableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
    imagesTableView.register(ImageLocationTableViewCell.self, forCellReuseIdentifier: ImageLocationTableViewCell.identifier)
    imagesTableView.separatorStyle = .none
    imagesTableView.dataSource = self
  }
  
  func setupLabel() {
    view.addSubview(statuslabel)
    statuslabel.translatesAutoresizingMaskIntoConstraints = false
    statuslabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    statuslabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    statuslabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9).isActive = true
  }
  
  func showAlert(withTitle title: String, message: String) {
    let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel)
    dialogMessage.addAction(cancelAction)
    present(dialogMessage, animated: true)
  }
}

extension ImagesLocationsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    images.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let imageUrl = images[indexPath.row]
    var locationImageCell = ImageLocationTableViewCell()
    if let reusedLocationImageCellCell = tableView.dequeueReusableCell(withIdentifier: ImageLocationTableViewCell.identifier,
                                                                       for: indexPath) as? ImageLocationTableViewCell {
      locationImageCell = reusedLocationImageCellCell
    }
    
    locationImageCell.updateCell(withViewModel: ImageLocationViewModel(imageFetcher: viewModel.imageFetcher,
                                                                   imageDataCache: viewModel.imageDataCache,
                                                                   imageUrl: imageUrl))
    return locationImageCell
  }
}

private extension ImagesLocationsViewModel.State {
  var alertTitle: String {
    switch self {
    case .stopped, .started, .image:
      return ""
    case .noPermission:
      return "No Location Permissions"
    case .failed:
      return "General Error"
    }
  }
  
  var alertMessage: String {
    switch self {
    case .stopped, .started, .image:
      return ""
    case .noPermission:
      return "Go to settings and change location permissions to always"
    case .failed(let error):
      switch error {
      case .locationError:
        return "Failed to get a location"
      case .imageFetchError:
        return "Failed to fetch an image by location"
      }
    }
  }
}
