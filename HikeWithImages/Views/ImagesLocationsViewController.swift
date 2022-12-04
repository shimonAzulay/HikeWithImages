//
//  ViewController.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import UIKit
import Combine

class ImagesLocationsViewController: UIViewController {
  private lazy var noImageslabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    label.text = "No Images Yet"
    label.font = .systemFont(ofSize: 30)
    label.textColor = .black
    return label
  }()
  
  private lazy var imagesTableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = .singleLine
    tableView.backgroundColor = .white
    return tableView
  }()
  
  private lazy var startStopHikeButton: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(toggleStartTapped))
    return barButtonItem
  }()
  
  private lazy var debugButton: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem(title: "Debug", style: .plain, target: self, action: #selector(debugTapped))
    return barButtonItem
  }()
  
  private var images = [Image]() {
    didSet {
      noImageslabel.isHidden = !images.isEmpty
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
        case .stopped:
          self?.startStopHikeButton.title = "Start"
        case .image(let image):
          self?.images.insert(image, at: 0)
        case .noPermission:
          break
        case .failed:
          break
        }
      }
        
    setupView()
    setupTableView()
    setupLabel()
  }
  
  @objc func toggleStartTapped() {
    viewModel.toggle()
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
    imagesTableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95).isActive = true
    imagesTableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
    imagesTableView.register(ImageLocationTableViewCell.self, forCellReuseIdentifier: ImageLocationTableViewCell.identifier)
    imagesTableView.separatorStyle = .none
    imagesTableView.dataSource = self
  }
  
  func setupLabel() {
    view.addSubview(noImageslabel)
    noImageslabel.translatesAutoresizingMaskIntoConstraints = false
    noImageslabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    noImageslabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    noImageslabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9).isActive = true
  }
}

extension ImagesLocationsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    images.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let image = images[indexPath.row]
    var locationImageCell = ImageLocationTableViewCell()
    if let reusedLocationImageCellCell = tableView.dequeueReusableCell(withIdentifier: ImageLocationTableViewCell.identifier,
                                                             for: indexPath) as? ImageLocationTableViewCell {
      locationImageCell = reusedLocationImageCellCell
    }

    locationImageCell.updateCell(with: image)
    return locationImageCell
  }
}

