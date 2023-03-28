//
//  MotionViewController.swift
//  MeasureUp
//
//  Created by brock davis on 3/26/23.
//

import UIKit
import CoreMotion
import CoreLocation

class DashboardViewController: UIViewController, CLLocationManagerDelegate {
    
    private let motionManager = CMMotionManager()
    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    
    // Scroll view
    private let scrollView = UIScrollView()
    private var contentLayoutBottomConstraint: NSLayoutConstraint!
    
    // Attitude
    private let attitudeLabel = UILabel()
    private let rollDataLabel = UILabel()
    private let rollLabel = UILabel()
    private let yawDataLabel = UILabel()
    private let yawLabel = UILabel()
    private let pitchDataLabel = UILabel()
    private let pitchLabel = UILabel()
    private let attitudeSeperator = UIView()
    private lazy var attitudeDataStack = UIStackView(arrangedSubviews: [rollDataLabel, pitchDataLabel, yawDataLabel])
    private lazy var attitudeDataNameStack = UIStackView(arrangedSubviews: [rollLabel, pitchLabel, yawLabel])

    // Gravity
    private let gravityLabel = UILabel()
    private let gravityXDataLabel = UILabel()
    private let gravityXLabel = UILabel()
    private let gravityYDataLabel = UILabel()
    private let gravityYLabel = UILabel()
    private let gravityZDataLabel = UILabel()
    private let gravityZLabel = UILabel()
    private let gravitySeperator = UIView()
    private lazy var gravityDataStack = UIStackView(arrangedSubviews: [gravityXDataLabel, gravityYDataLabel, gravityZDataLabel])
    private lazy var gravityDataNameStack = UIStackView(arrangedSubviews: [gravityXLabel, gravityYLabel, gravityZLabel])
    
    
    // User acceleration
    private let uaLabel = UILabel()
    private let uaXDataLabel = UILabel()
    private let uaXLabel = UILabel()
    private let uaYDataLabel = UILabel()
    private let uaYLabel = UILabel()
    private let uaZDataLabel = UILabel()
    private let uaZLabel = UILabel()
    private let uaSeperator = UIView()
    private lazy var uaDataStack = UIStackView(arrangedSubviews: [uaXDataLabel, uaYDataLabel, uaZDataLabel])
    private lazy var uaDataNameStack = UIStackView(arrangedSubviews: [uaXLabel, uaYLabel, uaZLabel])
    
    // Heading
    private let headingLabel = UILabel()
    private let headingDataLabel = UILabel()
    private let headingSeperator = UIView()
    
    // Magnetic Field
    private let mfLabel = UILabel()
    private let mfXDataLabel = UILabel()
    private let mfXLabel = UILabel()
    private let mfYDataLabel = UILabel()
    private let mfYLabel = UILabel()
    private let mfZDataLabel = UILabel()
    private let mfZLabel = UILabel()
    private let mfSeperator = UIView()
    private lazy var mfDataStack = UIStackView(arrangedSubviews: [mfXDataLabel, mfYDataLabel, mfZDataLabel])
    private lazy var mfDataNameStack = UIStackView(arrangedSubviews: [mfXLabel, mfYLabel, mfZLabel])
    
    // Location
    private let startLocationButton = UIButton()
    
    private let locationView = UIView()
    private let latitudeDataLabel = UILabel()
    private let latitudeLabel = UILabel()
    private let longitudeDataLabel = UILabel()
    private let longitudeLabel = UILabel()
    private let altitudeDataLabel = UILabel()
    private let altitudeLabel = UILabel()
    private let coordinatesSeperator = UIView()
    private let adddressDataContainer = UIView()
    private let addressDataLabel = UILabel()
    private let addressLabel = UILabel()
    private let addressSeperator = UIView()
    
    private let speedLabel = UILabel()
    private let speedDataLabel = UILabel()
    
    let filterAlpha = 0.1
    private var filteredValues = [String: Double]()

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLayoutSubviews() {
        for view in [self.attitudeDataStack.arrangedSubviews, self.gravityDataStack.arrangedSubviews, self.uaDataStack.arrangedSubviews, self.mfDataStack.arrangedSubviews].flatMap({$0}) {
            view.layer.cornerRadius = view.frame.width / 2
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = .black
        
        self.scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(self.scrollView) {
            $0.backgroundColor = .black
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                $0.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
                $0.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
        }
        
        let contentLayout = self.scrollView.contentLayoutGuide
        
        // Attitude
        self.attitudeLabel.attributedText = NSAttributedString(string: "Attitude:", attributes: Configurations.headerTextAttributes)
        self.scrollView.addSubview(self.attitudeLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.topAnchor.constraint(equalTo: contentLayout.topAnchor, constant: Configurations.headerTopConstant)
            ])
        }
        self.attitudeDataStack.axis = .horizontal
        self.attitudeDataStack.alignment = .center
        self.attitudeDataStack.distribution = .fillEqually
        self.attitudeDataStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.attitudeDataStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.dataLabelSpacing),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor, constant: -Configurations.dataLabelSpacing),
                $0.topAnchor.constraint(equalTo: attitudeLabel.bottomAnchor, constant: Configurations.dataStackTopConstant)
            ])
        }
        
        for dataLabel in self.attitudeDataStack.arrangedSubviews.compactMap({ $0 as? UILabel }) {
            dataLabel.layer.borderWidth = 2
            dataLabel.layer.masksToBounds = true
            dataLabel.backgroundColor = Configurations.dataBackgroundColor
            dataLabel.text = "0.0"
            dataLabel.font = Configurations.dataTextFont
            dataLabel.textColor = Configurations.textColor(for: 0.0)
            dataLabel.adjustsFontSizeToFitWidth = true
            dataLabel.textAlignment = .center
            dataLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dataLabel.heightAnchor.constraint(equalTo: dataLabel.widthAnchor),
            ])
        }
        
        self.attitudeDataNameStack.axis = .horizontal
        self.attitudeDataNameStack.alignment = .center
        self.attitudeDataNameStack.distribution = .fillEqually
        self.attitudeDataNameStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.attitudeDataNameStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.attitudeDataStack.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: self.attitudeDataStack.trailingAnchor),
                $0.topAnchor.constraint(equalTo: attitudeDataStack.bottomAnchor, constant: Configurations.dataNameStackTopConstant)
            ])
        }
        let dataNames = ["Roll", "Pitch", "Yaw"]
        for (ix, dataNameLabel) in self.attitudeDataNameStack.arrangedSubviews.compactMap({ $0 as? UILabel }).enumerated() {
            dataNameLabel.attributedText = NSAttributedString(string: dataNames[ix], attributes: Configurations.dataNameTextAttributes)
            dataNameLabel.textAlignment = .center
        }
        
        self.scrollView.addSubview(self.attitudeSeperator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.seperatorColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.attitudeDataNameStack.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        // Gravity
        self.gravityLabel.attributedText = NSAttributedString(string: "Gravity:", attributes: Configurations.headerTextAttributes)
        self.scrollView.addSubview(self.gravityLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.topAnchor.constraint(equalTo: self.attitudeSeperator.bottomAnchor, constant: Configurations.headerTopConstant)
            ])
        }
        
        self.gravityDataStack.axis = .horizontal
        self.gravityDataStack.alignment = .center
        self.gravityDataStack.distribution = .fillEqually
        self.gravityDataStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.gravityDataStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.dataLabelSpacing),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor, constant: -Configurations.dataLabelSpacing),
                $0.topAnchor.constraint(equalTo: gravityLabel.bottomAnchor, constant: Configurations.dataStackTopConstant)
            ])
        }
        
        for dataLabel in self.gravityDataStack.arrangedSubviews.compactMap({ $0 as? UILabel }) {
            dataLabel.layer.borderWidth = 2
            dataLabel.layer.masksToBounds = true
            dataLabel.backgroundColor = Configurations.dataBackgroundColor
            dataLabel.text = "0.0"
            dataLabel.font = Configurations.dataTextFont
            dataLabel.textColor = Configurations.textColor(for: 0.0)
            dataLabel.adjustsFontSizeToFitWidth = true
            dataLabel.textAlignment = .center
            dataLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dataLabel.heightAnchor.constraint(equalTo: dataLabel.widthAnchor)
            ])
        }
        
        self.gravityDataNameStack.axis = .horizontal
        self.gravityDataNameStack.alignment = .center
        self.gravityDataNameStack.distribution = .fillEqually
        self.gravityDataNameStack.spacing = Configurations.dataLabelSpacing
        self.gravityDataStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.gravityDataNameStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.gravityDataStack.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: self.gravityDataStack.trailingAnchor),
                $0.topAnchor.constraint(equalTo: gravityDataStack.bottomAnchor, constant: Configurations.dataNameStackTopConstant)
            ])
        }
        
        let xyzDataNames = ["X", "Y", "Z"]
        for (ix, dataNameLabel) in self.gravityDataNameStack.arrangedSubviews.compactMap({ $0 as? UILabel }).enumerated() {
            dataNameLabel.attributedText = NSAttributedString(string: xyzDataNames[ix], attributes: Configurations.dataNameTextAttributes)
            dataNameLabel.textAlignment = .center
            dataNameLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.scrollView.addSubview(self.gravitySeperator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.seperatorColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.gravityDataNameStack.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        // User accleration
        self.uaLabel.attributedText = NSAttributedString(string: "Acceleration:", attributes: Configurations.headerTextAttributes)
        self.scrollView.addSubview(self.uaLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.topAnchor.constraint(equalTo: self.gravitySeperator.bottomAnchor, constant: Configurations.headerTopConstant)
            ])
        }
        
        self.uaDataStack.axis = .horizontal
        self.uaDataStack.alignment = .center
        self.uaDataStack.distribution = .fillEqually
        self.uaDataStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.uaDataStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.dataLabelSpacing),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor, constant: -Configurations.dataLabelSpacing),
                $0.topAnchor.constraint(equalTo: uaLabel.bottomAnchor, constant: Configurations.dataStackTopConstant)
            ])
        }
        
        for dataLabel in self.uaDataStack.arrangedSubviews.compactMap({ $0 as? UILabel }) {
            dataLabel.layer.borderWidth = 2
            dataLabel.layer.masksToBounds = true
            dataLabel.backgroundColor = Configurations.dataBackgroundColor
            dataLabel.text = "0.0"
            dataLabel.font = Configurations.dataTextFont
            dataLabel.textColor = Configurations.textColor(for: 0.0)
            dataLabel.adjustsFontSizeToFitWidth = true
            dataLabel.textAlignment = .center
            dataLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dataLabel.heightAnchor.constraint(equalTo: dataLabel.widthAnchor)
            ])
        }
        
        self.uaDataNameStack.axis = .horizontal
        self.uaDataNameStack.alignment = .center
        self.uaDataNameStack.distribution = .fillEqually
        self.uaDataNameStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.uaDataNameStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.uaDataStack.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: self.uaDataStack.trailingAnchor),
                $0.topAnchor.constraint(equalTo: uaDataStack.bottomAnchor, constant: Configurations.dataNameStackTopConstant)
            ])
        }
    
        for (ix, dataNameLabel) in self.uaDataNameStack.arrangedSubviews.compactMap({ $0 as? UILabel }).enumerated() {
            dataNameLabel.attributedText = NSAttributedString(string: xyzDataNames[ix], attributes: Configurations.dataNameTextAttributes)
            dataNameLabel.textAlignment = .center
            dataNameLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.scrollView.addSubview(self.uaSeperator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.seperatorColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.uaDataNameStack.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        // Heading
        self.headingDataLabel.text = "0°"
        self.headingDataLabel.font = Configurations.headingTextFont
        self.headingDataLabel.textColor = Configurations.headingTextColor
        self.headingDataLabel.adjustsFontSizeToFitWidth = true
        self.headingDataLabel.textAlignment = .center
        self.headingDataLabel.backgroundColor = Configurations.dataBackgroundColor
        self.headingDataLabel.layer.cornerRadius = 10
        self.headingDataLabel.layer.masksToBounds = true
        self.scrollView.addSubview(self.headingDataLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: uaSeperator.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.widthAnchor.constraint(equalTo: self.gravityXDataLabel.widthAnchor, multiplier: 1.35),
                $0.heightAnchor.constraint(equalTo: self.gravityXDataLabel.heightAnchor, multiplier: 0.65)
            ])
        }
        self.headingLabel.attributedText = NSAttributedString(string: "Heading:", attributes: Configurations.headerTextAttributes)
        self.scrollView.addSubview(self.headingLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.headingDataLabel.centerYAnchor),
                self.headingDataLabel.leadingAnchor.constraint(equalTo: $0.trailingAnchor, constant: 10)
            ])
        }
    
        self.scrollView.addSubview(self.headingSeperator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.seperatorColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.headingDataLabel.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        // Magnetic Field
        self.mfLabel.attributedText = NSAttributedString(string: "Magnetic Field:", attributes: Configurations.headerTextAttributes)
        self.scrollView.addSubview(self.mfLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.topAnchor.constraint(equalTo: self.headingSeperator.bottomAnchor, constant: Configurations.headerTopConstant)
            ])
        }
        
        self.mfDataStack.axis = .horizontal
        self.mfDataStack.alignment = .center
        self.mfDataStack.distribution = .fillEqually
        self.mfDataStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.mfDataStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor, constant: Configurations.dataLabelSpacing),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor, constant: -Configurations.dataLabelSpacing),
                $0.topAnchor.constraint(equalTo: mfLabel.bottomAnchor, constant: Configurations.dataStackTopConstant)
            ])
        }
        
        for dataLabel in self.mfDataStack.arrangedSubviews.compactMap({ $0 as? UILabel }) {
            dataLabel.layer.borderWidth = 2
            dataLabel.layer.masksToBounds = true
            dataLabel.backgroundColor = Configurations.dataBackgroundColor
            dataLabel.text = "0.0"
            dataLabel.font = Configurations.dataTextFont
            dataLabel.textColor = Configurations.textColor(for: 0.0)
            dataLabel.adjustsFontSizeToFitWidth = true
            dataLabel.textAlignment = .center
            dataLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dataLabel.heightAnchor.constraint(equalTo: dataLabel.widthAnchor)
            ])
        }
        
        self.mfDataNameStack.axis = .horizontal
        self.mfDataNameStack.alignment = .center
        self.mfDataNameStack.distribution = .fillEqually
        self.mfDataNameStack.spacing = Configurations.dataLabelSpacing
        self.scrollView.addSubview(self.mfDataNameStack) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.mfDataStack.leadingAnchor),
                $0.trailingAnchor.constraint(equalTo: self.mfDataStack.trailingAnchor),
                $0.topAnchor.constraint(equalTo: mfDataStack.bottomAnchor, constant: Configurations.dataNameStackTopConstant)
            ])
        }
        
        for (ix, dataNameLabel) in self.mfDataNameStack.arrangedSubviews.compactMap({ $0 as? UILabel }).enumerated() {
            dataNameLabel.attributedText = NSAttributedString(string: xyzDataNames[ix], attributes: Configurations.dataNameTextAttributes)
            dataNameLabel.textAlignment = .center
            dataNameLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        self.scrollView.addSubview(self.mfSeperator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.seperatorColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.mfDataNameStack.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        // Start Location Button
        self.startLocationButton.backgroundColor = .blue
        self.startLocationButton.layer.cornerRadius = 10
        self.startLocationButton.layer.masksToBounds = true
        self.startLocationButton.setAttributedTitle(NSAttributedString(string: "Start location data", attributes: [
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "RobotoMono-Medium", size: 20)!
        ]), for: .normal)
        self.startLocationButton.addTarget(self, action: #selector(self.handleStartLocationButtonTap), for: .touchUpInside)
        self.scrollView.addSubview(self.startLocationButton) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: contentLayout.centerXAnchor),
                $0.topAnchor.constraint(equalTo: mfSeperator.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.widthAnchor.constraint(equalTo: contentLayout.widthAnchor, multiplier: 0.75),
                $0.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        // Location View
        self.scrollView.addSubview(self.locationView) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: contentLayout.leadingAnchor),
                $0.topAnchor.constraint(equalTo: mfSeperator.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: contentLayout.trailingAnchor)
            ])
        }
        
        // Coordinates
        self.locationView.addSubview(self.latitudeDataLabel) {
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.backgroundColor = Configurations.dataBackgroundColor
            $0.textAlignment = .center
            $0.text = "0"
            $0.textColor = Configurations.coordinatesTextColor
            $0.font = Configurations.coordinatesTextFont
            $0.adjustsFontSizeToFitWidth = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: self.locationView.topAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: self.locationView.trailingAnchor, constant: -Configurations.dataLabelSpacing),
                $0.heightAnchor.constraint(equalTo: self.headingDataLabel.heightAnchor)
            ])
        }
        
        self.locationView.addSubview(self.latitudeLabel) {
            $0.attributedText = NSAttributedString(string: "Latitude: ", attributes: Configurations.headerTextAttributes)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.latitudeDataLabel.centerYAnchor),
                $0.widthAnchor.constraint(equalToConstant: self.latitudeLabel.intrinsicContentSize.width),
                self.latitudeDataLabel.leadingAnchor.constraint(equalTo: $0.trailingAnchor, constant: 10)
            ])
        }
        
        self.locationView.addSubview(self.longitudeDataLabel) {
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.dataBackgroundColor
            $0.textAlignment = .center
            $0.text = "0"
            $0.textColor = Configurations.coordinatesTextColor
            $0.font = Configurations.coordinatesTextFont
            $0.adjustsFontSizeToFitWidth = true
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.latitudeDataLabel.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.latitudeDataLabel.bottomAnchor, constant: 20),
                $0.trailingAnchor.constraint(equalTo: self.latitudeDataLabel.trailingAnchor),
                $0.heightAnchor.constraint(equalTo: self.latitudeDataLabel.heightAnchor)
            ])
        }
    
        self.locationView.addSubview(self.longitudeLabel) {
            $0.attributedText = NSAttributedString(string: "Longitude: ", attributes: Configurations.headerTextAttributes)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.longitudeDataLabel.centerYAnchor),
                $0.widthAnchor.constraint(equalToConstant: self.longitudeLabel.intrinsicContentSize.width)
            ])
        }
        
        self.locationView.addSubview(self.altitudeDataLabel) {
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.backgroundColor = Configurations.dataBackgroundColor
            $0.text = "0ft"
            $0.textColor = Configurations.coordinatesTextColor
            $0.font = Configurations.coordinatesTextFont
            $0.adjustsFontSizeToFitWidth = true
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.longitudeDataLabel.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.longitudeDataLabel.bottomAnchor, constant: 20),
                $0.trailingAnchor.constraint(equalTo: self.longitudeDataLabel.trailingAnchor),
                $0.heightAnchor.constraint(equalTo: self.longitudeDataLabel.heightAnchor)
            ])
        }
        
        self.locationView.addSubview(self.altitudeLabel) {
            $0.attributedText = NSAttributedString(string: "Altitude: ", attributes: Configurations.headerTextAttributes)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.altitudeDataLabel.centerYAnchor),
                $0.widthAnchor.constraint(equalToConstant: self.altitudeLabel.intrinsicContentSize.width)
            ])
        }
        
        self.locationView.addSubview(self.coordinatesSeperator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.seperatorColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.altitudeDataLabel.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: self.locationView.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        // Address
        self.addressLabel.attributedText = NSAttributedString(string: "📍Address:", attributes: Configurations.headerTextAttributes)
        self.locationView.addSubview(self.addressLabel) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.topAnchor.constraint(equalTo: self.coordinatesSeperator.bottomAnchor, constant: Configurations.headerTopConstant)
            ])
        }
        
        self.locationView.addSubview(self.adddressDataContainer) {
            $0.layer.cornerRadius = 10
            $0.backgroundColor = Configurations.dataBackgroundColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: self.locationView.centerXAnchor),
                $0.topAnchor.constraint(equalTo: self.addressLabel.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.widthAnchor.constraint(equalTo: self.locationView.widthAnchor, multiplier: 0.85),
                $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 0.275)
            ])
        }
        
        self.adddressDataContainer.addSubview(self.addressDataLabel) {
            $0.textAlignment = .center
            $0.numberOfLines = 2
            $0.adjustsFontSizeToFitWidth = true
            $0.font = Configurations.addressTextFont
            $0.textColor = Configurations.addressTextColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.centerXAnchor.constraint(equalTo: self.adddressDataContainer.centerXAnchor),
                $0.centerYAnchor.constraint(equalTo: self.adddressDataContainer.centerYAnchor),
                $0.widthAnchor.constraint(equalTo: self.adddressDataContainer.widthAnchor, multiplier: 0.9),
                $0.heightAnchor.constraint(equalTo: self.adddressDataContainer.heightAnchor, multiplier: 0.9)
            ])
        }
        
        self.locationView.addSubview(self.addressSeperator) {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = Configurations.seperatorColor
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor),
                $0.topAnchor.constraint(equalTo: self.adddressDataContainer.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.trailingAnchor.constraint(equalTo: self.locationView.trailingAnchor),
                $0.heightAnchor.constraint(equalToConstant: 0.5)
            ])
        }
        
        
        self.locationView.addSubview(self.speedDataLabel) {
            $0.textColor = .black
            $0.font = Configurations.speedDataTextFont
            $0.adjustsFontSizeToFitWidth = true
            $0.textAlignment = .center
            $0.layer.cornerRadius = 10
            $0.layer.masksToBounds = true
            $0.text = "0mph"
            $0.backgroundColor = Configurations.dataBackgroundColor
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.topAnchor.constraint(equalTo: self.addressSeperator.bottomAnchor, constant: Configurations.headerTopConstant),
                $0.widthAnchor.constraint(equalTo: self.altitudeDataLabel.widthAnchor),
                $0.heightAnchor.constraint(equalTo: self.altitudeDataLabel.heightAnchor),
                $0.leadingAnchor.constraint(equalTo: self.altitudeDataLabel.leadingAnchor)
            ])
        }
        
        self.locationView.addSubview(self.speedLabel) {
            $0.attributedText = NSAttributedString(string: "Speed:", attributes: Configurations.headerTextAttributes)
            $0.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                $0.leadingAnchor.constraint(equalTo: self.locationView.leadingAnchor, constant: Configurations.headerLeadingConstant),
                $0.centerYAnchor.constraint(equalTo: self.speedDataLabel.centerYAnchor)
            ])
        }

        
        self.locationView.bottomAnchor.constraint(equalTo: self.speedDataLabel.bottomAnchor, constant: Configurations.headerTopConstant).isActive = true
        
        // Scroll View Content Size
        self.contentLayoutBottomConstraint =  contentLayout.bottomAnchor.constraint(equalTo: self.startLocationButton.bottomAnchor, constant: Configurations.headerTopConstant)
        NSLayoutConstraint.activate([
            contentLayout.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.contentLayoutBottomConstraint
        ])
        
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    @objc private func handleStartLocationButtonTap() {
        let authStatus: CLAuthorizationStatus
        if #available(iOS 14, *) {
            authStatus = self.locationManager.authorizationStatus
        } else {
            authStatus = CLLocationManager.authorizationStatus()
        }
        
        if authStatus == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        } else if authStatus == .denied, let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Set up motion updates
        if !self.motionManager.isDeviceMotionActive, self.motionManager.isDeviceMotionAvailable {
            self.motionManager.showsDeviceMovementDisplay = true
            self.motionManager.deviceMotionUpdateInterval = 1.0 / 30.0
            let refFrame: CMAttitudeReferenceFrame
            if CMMotionManager.availableAttitudeReferenceFrames().contains(CMAttitudeReferenceFrame.xTrueNorthZVertical) {
                refFrame = CMAttitudeReferenceFrame.xTrueNorthZVertical
            } else if CMMotionManager.availableAttitudeReferenceFrames().contains(CMAttitudeReferenceFrame.xMagneticNorthZVertical) {
                refFrame = CMAttitudeReferenceFrame.xMagneticNorthZVertical
            } else if CMMotionManager.availableAttitudeReferenceFrames().contains(CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical) {
                refFrame = CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical
            } else {
                refFrame = CMAttitudeReferenceFrame.xArbitraryZVertical
            }
            self.motionManager.startDeviceMotionUpdates(using: refFrame, to: .main, withHandler: self.handleMotionUpdate(data:error:))
        }
        
        self.updateLocationLayout()
    }
    
    private func updateLocationLayout() {
        let authStatus: CLAuthorizationStatus
        if #available(iOS 14, *) {
            authStatus = self.locationManager.authorizationStatus
        } else {
            authStatus = CLLocationManager.authorizationStatus()
        }
        if authStatus == .notDetermined || authStatus == .denied {
            self.startLocationButton.isHidden = false
            self.locationView.isHidden = true
            if (self.contentLayoutBottomConstraint.secondItem as? UIButton) != self.startLocationButton {
                self.contentLayoutBottomConstraint.isActive = false
                self.contentLayoutBottomConstraint = self.scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.startLocationButton.bottomAnchor, constant: Configurations.headerTopConstant)
                self.contentLayoutBottomConstraint.isActive = true
            }
        } else {
            self.startLocationButton.isHidden = true
            self.locationView.isHidden = false
            if (self.contentLayoutBottomConstraint.secondItem as? UIView) != self.locationView {
                self.contentLayoutBottomConstraint.isActive = false
                self.contentLayoutBottomConstraint = self.scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: self.locationView.bottomAnchor, constant: Configurations.headerTopConstant)
                self.contentLayoutBottomConstraint.isActive = true
            }
            self.locationManager.startUpdatingLocation()
        }
    }
    
    
    // Pre iOS 14 Delegate method
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.updateLocationLayout()
    }
    
    // iOS 14+ delegate method
    @available(iOS 14, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.updateLocationLayout()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
    
        self.latitudeDataLabel.text = String(round(location.coordinate.latitude, todecimalPlaces: 7))
    
        self.longitudeDataLabel.text = String(round(location.coordinate.longitude, todecimalPlaces: 7))
        
        self.altitudeDataLabel.text = String(round(location.altitude * 3.281, todecimalPlaces: 2)) + "ft"
        
        let speed: Int = location.speed <= 0.0 ? 0 : Int((location.speed * 2.237))
        self.speedDataLabel.text = String(speed) + "mph"
        
        self.geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            
            guard error == nil, let placemark = placemarks?.last else {
                return
            }

            let addressText: String
            if let ocean = placemark.ocean {
                addressText = ocean
            } else if let inlandWater = placemark.inlandWater {
                addressText = inlandWater
            } else if placemark.thoroughfare == nil, let locality = placemark.locality {
                addressText = locality + (placemark.administrativeArea == nil ? "" : ", " + placemark.administrativeArea!) + (placemark.postalCode == nil ? "" : " " + placemark.postalCode!) + (placemark.country == nil ? "" : ", " + placemark.country!)
            } else if let street = placemark.thoroughfare {
                addressText = (placemark.subThoroughfare == nil ? "" : placemark.subThoroughfare! + " ") + street + (placemark.locality == nil ? "" : ", " + placemark.locality!) + (placemark.administrativeArea == nil ? "" : ", " + placemark.administrativeArea!) + (placemark.postalCode == nil ? "" : " " + placemark.postalCode!) + (placemark.country == nil ? "" : ", " + placemark.country!)
            } else {
                addressText = ""
            }
            self.addressDataLabel.text = addressText
        }
    }
    
    private func round(_ number: Double, todecimalPlaces decimalPlaces: Int) -> Double {
        let magnitude = pow(10.0, Double(decimalPlaces))
        var retval = Darwin.round(number * magnitude) / magnitude
        retval = retval.isZero ? 0.0 : retval
        return retval
    }
    
    private func handleMotionUpdate(data: CMDeviceMotion?, error: Error?) {
        
        guard error == nil else {
            self.motionManager.stopDeviceMotionUpdates()
            return
        }
        
        guard let data else { return }
    
        
        func degrees(_ radians: Double) -> Double {
            return radians * 180.0 / .pi
        }
        
        // Update attitude
        let currentRoll = self.filteredValues["attitude.roll", default: 0.0]
        self.filteredValues["attitude.roll"] = currentRoll * (1.0 - self.filterAlpha) + self.filterAlpha * data.attitude.roll
        let formattedRoll = round(degrees(self.filteredValues["attitude.roll"]!), todecimalPlaces: 1)
        
        let currentPitch = self.filteredValues["attitude.pitch", default: 0.0]
        self.filteredValues["attitude.pitch"] = currentPitch * (1.0 - self.filterAlpha) + self.filterAlpha * data.attitude.pitch
        let formattedPitch = round(degrees(self.filteredValues["attitude.pitch"]!), todecimalPlaces: 1)
        
        let currentYaw = self.filteredValues["attitude.yaw", default: 0.0]
        self.filteredValues["attitude.yaw"] = currentYaw * (1.0 - self.filterAlpha) + self.filterAlpha * data.attitude.yaw
        let formattedYaw = round(degrees(self.filteredValues["attitude.yaw"]!), todecimalPlaces: 1)
        
        self.rollDataLabel.text = String(formattedRoll)
        self.rollDataLabel.textColor = Configurations.textColor(for: formattedRoll)
        self.rollDataLabel.layer.borderColor = Configurations.borderColor(for: formattedRoll)
        self.pitchDataLabel.text = String(formattedPitch)
        self.pitchDataLabel.textColor = Configurations.textColor(for: formattedPitch)
        self.pitchDataLabel.layer.borderColor = Configurations.borderColor(for: formattedPitch)
        self.yawDataLabel.text = String(formattedYaw)
        self.yawDataLabel.textColor = Configurations.textColor(for: formattedYaw)
        self.yawDataLabel.layer.borderColor = Configurations.borderColor(for: formattedYaw)
        
        // Update gravity
        let currentGravityX = self.filteredValues["gravity.x", default: 0.0]
        self.filteredValues["gravity.x"] = currentGravityX * (1.0 - self.filterAlpha) + data.gravity.x * self.filterAlpha
        let formattedGravityX = round(self.filteredValues["gravity.x"]!, todecimalPlaces: 1)
        
        let currentGravityY = self.filteredValues["gravity.y", default: 0.0]
        self.filteredValues["gravity.y"] = currentGravityY * (1.0 - self.filterAlpha) + data.gravity.y * self.filterAlpha
        let formattedGravityY = round(self.filteredValues["gravity.y"]!, todecimalPlaces: 1)
        
        let currentGravityZ = self.filteredValues["gravity.z", default: 0.0]
        self.filteredValues["gravity.z"] = currentGravityZ * (1.0 - self.filterAlpha) + data.gravity.z * self.filterAlpha
        let formattedGravityZ = round(self.filteredValues["gravity.z"]!, todecimalPlaces: 1)
        
        self.gravityXDataLabel.text = String(formattedGravityX)
        self.gravityXDataLabel.textColor = Configurations.textColor(for: formattedGravityX)
        self.gravityXDataLabel.layer.borderColor = Configurations.borderColor(for: formattedGravityX)
        self.gravityYDataLabel.text = String(formattedGravityY)
        self.gravityYDataLabel.textColor = Configurations.textColor(for: formattedGravityY)
        self.gravityYDataLabel.layer.borderColor = Configurations.borderColor(for: formattedGravityY)
        self.gravityZDataLabel.text = String(formattedGravityZ)
        self.gravityZDataLabel.textColor = Configurations.textColor(for: formattedGravityZ)
        self.gravityZDataLabel.layer.borderColor = Configurations.borderColor(for: formattedGravityZ)
        
        // Update user acceleration
        let currentXAcceleration = self.filteredValues["useracceleration.x", default: 0.0]
        self.filteredValues["useracceleration.x"] = currentXAcceleration * (1.0 - self.filterAlpha) + data.userAcceleration.x * self.filterAlpha
        let formattedXAcceleration = round(self.filteredValues["useracceleration.x"]!, todecimalPlaces: 1)
        
        let currentYAcceleration = self.filteredValues["useracceleration.y", default: 0.0]
        self.filteredValues["useracceleration.y"] = currentYAcceleration * (1.0 - self.filterAlpha) + data.userAcceleration.y * self.filterAlpha
        let formattedYAcceleration = round(self.filteredValues["useracceleration.y"]!, todecimalPlaces: 1)
        
        let currentZAcceleration = self.filteredValues["useracceleration.z", default: 0.0]
        self.filteredValues["useracceleration.z"] = currentZAcceleration * (1.0 - self.filterAlpha) + data.userAcceleration.z * self.filterAlpha
        let formattedZAcceleration = round(self.filteredValues["useracceleration.z"]!, todecimalPlaces: 1)
        self.uaXDataLabel.text = String(formattedXAcceleration)
        self.uaXDataLabel.textColor = Configurations.textColor(for: formattedXAcceleration)
        self.uaXDataLabel.layer.borderColor = Configurations.borderColor(for: formattedXAcceleration)
        self.uaYDataLabel.text = String(formattedYAcceleration)
        self.uaYDataLabel.textColor = Configurations.textColor(for: formattedYAcceleration)
        self.uaYDataLabel.layer.borderColor = Configurations.borderColor(for: formattedYAcceleration)
        self.uaZDataLabel.text = String(formattedZAcceleration)
        self.uaZDataLabel.textColor = Configurations.textColor(for: formattedZAcceleration)
        self.uaZDataLabel.layer.borderColor = Configurations.borderColor(for: formattedZAcceleration)
        
        // Update heading
        if data.heading != -1.0 {
            self.headingDataLabel.text = String(data.heading.rounded()) + "°"
        }
        
        // Update magnetic field
        let currentMFX = self.filteredValues["magneticfield.x", default: 0.0]
        self.filteredValues["magneticfield.x"] = currentMFX * (1.0 - self.filterAlpha) + data.magneticField.field.x * self.filterAlpha
        let formattedMFX = round(self.filteredValues["magneticfield.x"]!, todecimalPlaces: 1)
        
        let currentMFY = self.filteredValues["magneticfield.y", default: 0.0]
        self.filteredValues["magneticfield.y"] = currentMFY * (1.0 - self.filterAlpha) + data.magneticField.field.y * self.filterAlpha
        let formattedMFY = round(self.filteredValues["magneticfield.y"]!, todecimalPlaces: 1)
        
        let currentMFZ = self.filteredValues["magneticfield.z", default: 0.0]
        self.filteredValues["magneticfield.z"] = currentMFZ * (1.0 - self.filterAlpha) + data.magneticField.field.z * self.filterAlpha
        let formattedMFZ = round(self.filteredValues["magneticfield.z"]!, todecimalPlaces: 1)
        
        self.mfXDataLabel.text = String(formattedMFX)
        self.mfXDataLabel.textColor = Configurations.textColor(for: formattedMFX)
        self.mfXDataLabel.layer.borderColor = Configurations.borderColor(for: formattedMFX)
        self.mfYDataLabel.text = String(formattedMFY)
        self.mfYDataLabel.textColor = Configurations.textColor(for: formattedMFY)
        self.mfYDataLabel.layer.borderColor = Configurations.borderColor(for: formattedMFY)
        self.mfZDataLabel.text = String(formattedMFZ)
        self.mfZDataLabel.textColor = Configurations.textColor(for: formattedMFZ)
        self.mfZDataLabel.layer.borderColor = Configurations.borderColor(for: formattedMFZ)
    }
}

private struct Configurations {
    
    static let screenWidth = UIScreen.main.bounds.width
    
    static let headerTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "RobotoMono-Bold", size: screenWidth / 16)!
    ]
    
    static let dataTextFont = UIFont(name: "RobotoMono-Regular", size: screenWidth / 17.0)!
    private static let negativeDataTextColor = UIColor(named: "negativeDataTextColor")!
    private static let positiveDataTextColor = UIColor(named: "positiveDataTextColor")!
    
    static func borderColor(for number: Double) -> CGColor {
        if number.isZero { return seperatorColor.cgColor }
        else { return number > 0.0 ? positiveDataTextColor.cgColor : negativeDataTextColor.cgColor }
    }
    
    static func textColor(for number: Double) -> UIColor {
        if number.isZero { return .black }
        else { return number > 0.0 ? positiveDataTextColor : negativeDataTextColor }
    }

    static let headingTextColor = UIColor.black
    static let headingTextFont = dataTextFont
    
    static let dataNameTextAttributes: [NSAttributedString.Key: Any] = [
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "RobotoMono-Medium", size: screenWidth / 23.0)!
    ]
    
    static let coordinatesTextColor = UIColor.black
    static let coordinatesTextFont = UIFont(name: "RobotoMono-Regular", size: screenWidth / 20.0)!
    
    
    static let addressTextColor = UIColor.black
    static let addressTextFont = UIFont(name: "RobotoMono-Regular", size: screenWidth / 20.0)!
    
    static let speedDataTextFont = UIFont(name: "RobotoMono-Regular", size: screenWidth / 20.0)!
    
    static let seperatorColor = UIColor(named: "seperatorColor")!
    
    static let dataBackgroundColor = UIColor(named: "dataBackgroundColor")!
    
    static let headerTopConstant: CGFloat = 25.0
    
    static let headerLeadingConstant: CGFloat = UIScreen.main.bounds.width / 15
    
    static let dataLabelSpacing: CGFloat = screenWidth / 12
    
    static let dataStackTopConstant: CGFloat = 30.0
    
    static let dataNameStackTopConstant: CGFloat = 5.0
}
