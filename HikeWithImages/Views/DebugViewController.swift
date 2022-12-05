//
//  DebugViewController.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 04/12/2022.
//

import UIKit
import MapKit

class DebugViewController: UIViewController {
  private lazy var containerView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .fill
    stackView.distribution = .fill
    stackView.spacing = 20
    return stackView
  }()
  
  private lazy var yourLocationsLabel: UILabel = {
    let yourLocationsLabel = UILabel()
    yourLocationsLabel.textAlignment = .center
    yourLocationsLabel.numberOfLines = 0
    yourLocationsLabel.lineBreakMode = .byWordWrapping
    yourLocationsLabel.textColor = .black
    yourLocationsLabel.font = .systemFont(ofSize: 20)
    yourLocationsLabel.text = "Your Locations"
    return yourLocationsLabel
  }()
  
  private lazy var mapView: MKMapView = {
    let map = MKMapView()
    map.mapType = MKMapType.standard
    map.isZoomEnabled = true
    map.isScrollEnabled = true
    map.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    map.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    return map
  }()
  
  private lazy var saveLocations: UIButton = {
    let loginButton = UIButton(type: .system)
    loginButton.setTitle("Save locations to disk", for: .normal)
    loginButton.addTarget(self, action: #selector(saveLocations(_:)), for: .touchUpInside)
    return loginButton
  }()
  
  private lazy var configurationTitles: UILabel = {
    let configurationTitles = UILabel()
    configurationTitles.textAlignment = .center
    configurationTitles.numberOfLines = 0
    configurationTitles.lineBreakMode = .byWordWrapping
    configurationTitles.textColor = .black
    configurationTitles.font = .systemFont(ofSize: 20)
    configurationTitles.text = "Set distance filter and accuracy"
    return configurationTitles
  }()
  
  
  private lazy var configurationPicker: UIPickerView = {
    let picker = UIPickerView()
    picker.tintColor = .black
    return picker
  }()
  
  var locationProvider: LocationProvider?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    view.addSubview(containerView)
    containerView.addArrangedSubview(yourLocationsLabel)
    containerView.addArrangedSubview(mapView)
    containerView.addArrangedSubview(saveLocations)
    containerView.addArrangedSubview(configurationTitles)
    containerView.addArrangedSubview(configurationPicker)
    
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9).isActive = true
    containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
    containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
    
    configurationPicker.delegate = self
    configurationPicker.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let distanceFilter = locationProvider?.distanceFilter,
          let accuracy = locationProvider?.accuracy else { return }
    
    configurationPicker.selectRow(distanceFilter, inComponent: 0, animated: true)
    configurationPicker.selectRow(accuracy - 1, inComponent: 1, animated: true)
    
    showAnnotations()
  }
  
  @objc func saveLocations(_ sender: UIButton) {
    guard let locations = locationProvider?.locations,
          let endcodedLocations = try? JSONEncoder().encode(locations)
    else {
      print("Failed to encode locations")
      return
    }
    
    let activityViewController = UIActivityViewController(activityItems: [endcodedLocations], applicationActivities: nil)
    present(activityViewController, animated: true)
  }
  
  func showAnnotations() {
    guard let locations = locationProvider?.locations else { return }
    for (index, location) in locations.enumerated() {
      let info = "Location #\(index + 1)"
      mapView.addAnnotation(MapAnnotation(title: info, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                          info: info))
    }
    guard let startingPoint = locations.first else { return }
    let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: startingPoint.latitude, longitude: startingPoint.longitude),
                                    latitudinalMeters: 500,
                                    longitudinalMeters: 500)
    mapView.setRegion(region, animated: true)
  }
}

class MapAnnotation: NSObject, MKAnnotation {
  let title: String?
  let coordinate: CLLocationCoordinate2D
  let info: String
  
  init(title: String?, coordinate: CLLocationCoordinate2D, info: String) {
    self.title = title
    self.coordinate = coordinate
    self.info = info
  }
}

extension DebugViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    component == 0 ? 101 : 16
  }
  
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    let rowString = component == 0 ? "\(row)" : "\(row + 1)"
    return NSAttributedString(string: rowString,
                              attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if component == 0 {
      locationProvider?.distanceFilter = row
    } else {
      locationProvider?.accuracy = row + 1
    }
  }
}
