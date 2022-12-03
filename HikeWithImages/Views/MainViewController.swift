//
//  ViewController.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 03/12/2022.
//

import UIKit
import Combine

class MainViewController: UIViewController {
  private lazy var activityIndicator: UIActivityIndicatorView = {
    UIActivityIndicatorView(style: .large)
  }()
  
  private lazy var imagesTableView: UITableView = {
    let tableView = UITableView()
    tableView.separatorStyle = .singleLine
    return tableView
  }()
  
  private lazy var startStopHikeButton: UIBarButtonItem = {
    let barButtonItem = UIBarButtonItem(title: "Start", style: .plain, target: self, action: #selector(toggleStartTapped))
    return barButtonItem
  }()
  
  private var cancellables = Set<AnyCancellable>()
  private let viewModel: ImageLocationViewModel
  
  init(viewModel: ImageLocationViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.$images
      .receive(on: DispatchQueue.main)
      .sink { [weak self] images in
        if images.isEmpty {
          self?.activityIndicator.startAnimating()
          self?.activityIndicator.isHidden = false
        } else {
          self?.activityIndicator.stopAnimating()
          self?.activityIndicator.isHidden = true
        }
        
        self?.imagesTableView.reloadData()
      }
      .store(in: &cancellables)
        
      viewModel.$started
      .receive(on: DispatchQueue.main)
      .sink { [weak self] started in
        self?.startStopHikeButton.title = started ? "Stop" : "Start"
      }
      .store(in: &cancellables)
    
    setupView()
    setupTableView()
    setupActivityIndicator()
  }
  
  @objc func toggleStartTapped() {
    viewModel.toggle()
  }
}

private extension MainViewController {
  func setupView() {
    navigationItem.rightBarButtonItem  = startStopHikeButton
    view.backgroundColor = .white
  }
  
  func setupTableView() {
    imagesTableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(imagesTableView)
    imagesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    imagesTableView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    imagesTableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.95).isActive = true
    imagesTableView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
    imagesTableView.register(LocationImageTableViewCell.self, forCellReuseIdentifier: LocationImageTableViewCell.identifier)
    imagesTableView.separatorStyle = .none
    imagesTableView.dataSource = self
  }
  
  func setupActivityIndicator() {
    view.addSubview(activityIndicator)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    activityIndicator.startAnimating()
  }
}

extension MainViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    viewModel.images.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let image = viewModel.images[indexPath.row]
    var locationImageCell = LocationImageTableViewCell()
    if let reusedLocationImageCellCell = tableView.dequeueReusableCell(withIdentifier: LocationImageTableViewCell.identifier,
                                                             for: indexPath) as? LocationImageTableViewCell {
      locationImageCell = reusedLocationImageCellCell
    }

    locationImageCell.updateCell(with: image)
    return locationImageCell
  }
}

