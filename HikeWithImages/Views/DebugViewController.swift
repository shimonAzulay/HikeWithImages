//
//  DebugViewController.swift
//  HikeWithImages
//
//  Created by Shimon Azulay on 04/12/2022.
//

import UIKit

class DebugViewController: UIViewController {
  private lazy var containerView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .fill
    stackView.spacing = 15
    return stackView
  }()
  
  private lazy var distanceFilterSwitch: UISwitch = {
    let distanceFilterSwitch = UISwitch()
    distanceFilterSwitch.addTarget(self, action: #selector(distanceFilterSwitchChanged), for: .valueChanged)
    distanceFilterSwitch.isOn = true
    return distanceFilterSwitch
  }()
  
  private lazy var distanceFilterPickerLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.text = "Update location every X meters"
    label.textColor = .black
    label.font = .systemFont(ofSize: 18)
    return label
  }()
  
  private lazy var saveLocations: UIButton = {
    let loginButton = UIButton(type: .system)
    loginButton.setTitle("Save last location to disk", for: .normal)
    loginButton.addTarget(self, action: #selector(saveLocations(_:)), for: .touchUpInside)
    return loginButton
  }()
  
  private lazy var distanceFilterLabel: UILabel = {
    let label = UILabel()
    label.lineBreakMode = .byWordWrapping
    label.numberOfLines = 0
    label.text = "Update location every X meters"
    label.textColor = .black
    label.font = .systemFont(ofSize: 18)
    return label
  }()
  
  private lazy var distanceFilterPicker: UIPickerView = {
    let picker = UIPickerView()
    picker.tintColor = .black
    return picker
  }()
  
  var locationProvider: LocationProvider?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white

    view.addSubview(containerView)
    containerView.addArrangedSubview(saveLocations)
    containerView.addArrangedSubview(distanceFilterLabel)
    containerView.addArrangedSubview(distanceFilterSwitch)
    containerView.addArrangedSubview(distanceFilterPicker)
  
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
    containerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    
    containerView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    containerView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    distanceFilterPicker.delegate = self
    distanceFilterPicker.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    guard let distanceFilter = locationProvider?.distanceFilter else {
      distanceFilterSwitch.isOn = false
      distanceFilterPicker.isUserInteractionEnabled = false
      distanceFilterPicker.alpha = 0.5
      return
    }
    
    distanceFilterPicker.selectRow(distanceFilter - 1, inComponent: 0, animated: true)
  }
  
  @objc func distanceFilterSwitchChanged() {
    locationProvider?.distanceFilter = distanceFilterSwitch.isOn ? 100 : nil
    distanceFilterPicker.selectRow(99, inComponent: 0, animated: true)
    distanceFilterPicker.isUserInteractionEnabled = distanceFilterSwitch.isOn
    distanceFilterPicker.alpha = distanceFilterSwitch.isOn ? 1.0 : 0.5
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
}

extension DebugViewController: UIPickerViewDelegate, UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int { 100 }
  func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
    NSAttributedString(string: "\(row + 1)", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    locationProvider?.distanceFilter = row + 1
  }
}
