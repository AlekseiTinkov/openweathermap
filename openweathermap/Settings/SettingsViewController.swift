import UIKit

final class SettingsViewController: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Units".localized
        return label
    }()
    
    private lazy var tempLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "Temperature".localized
        return label
    }()
    
    private lazy var windLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "Wind speed".localized
        return label
    }()
    
    private lazy var pressureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = "Atmospheric pressure".localized
        return label
    }()
    
    private lazy var tempSegmentedControl: UISegmentedControl = {
        let items = TempUnits.allCases.map {$0.name}
        let segmentedControl = UISegmentedControl(items: items)

        segmentedControl.layer.cornerRadius = 5.0
        segmentedControl.backgroundColor = UIColor.colorGray
        segmentedControl.tintColor = UIColor.colorWhite
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.colorBlack, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        segmentedControl.addTarget(self, action: #selector(tempSegmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex =  SettingsVarible.shared.units.tempUnits.rawValue
        return segmentedControl
    }()
    
    private lazy var windSegmentedControl: UISegmentedControl = {
        let items = WindUnits.allCases.map {$0.name}
        let segmentedControl = UISegmentedControl(items: items)

        segmentedControl.layer.cornerRadius = 5.0
        segmentedControl.backgroundColor = UIColor.colorGray
        segmentedControl.tintColor = UIColor.colorWhite
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.colorBlack, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        segmentedControl.addTarget(self, action: #selector(windSegmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = SettingsVarible.shared.units.windUnits.rawValue
        return segmentedControl
    }()
    
    private lazy var pressureSegmentedControl: UISegmentedControl = {
        let items = PressureUnits.allCases.map {$0.name}
        let segmentedControl = UISegmentedControl(items: items)

        segmentedControl.layer.cornerRadius = 5.0
        segmentedControl.backgroundColor = UIColor.colorGray
        segmentedControl.tintColor = UIColor.colorWhite
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.colorBlack, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
        
        segmentedControl.addTarget(self, action: #selector(pressureSegmentAction(_:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = SettingsVarible.shared.units.pressureUnits.rawValue
        return segmentedControl
    }()
    
    @objc
    func tempSegmentAction(_ segmentedControl: UISegmentedControl) {
        SettingsVarible.shared.setTempUnits(tempUnits: TempUnits(rawValue: segmentedControl.selectedSegmentIndex) ?? .celsius)
    }
    
    @objc
    func windSegmentAction(_ segmentedControl: UISegmentedControl) {
        SettingsVarible.shared.setWindUnits(windUnits: WindUnits(rawValue: segmentedControl.selectedSegmentIndex) ?? .metrPerSec)
    }
    
    @objc
    func pressureSegmentAction(_ segmentedControl: UISegmentedControl) {
        SettingsVarible.shared.setPressureUnits(pressureUnits: PressureUnits(rawValue: segmentedControl.selectedSegmentIndex) ?? .hPa)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .colorWhite
        
        [titleLabel, tempLabel, tempSegmentedControl, windLabel, windSegmentedControl, pressureLabel, pressureSegmentedControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tempLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tempLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tempSegmentedControl.centerYAnchor.constraint(equalTo: tempLabel.centerYAnchor),
            tempSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            windLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 24),
            windLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            windSegmentedControl.centerYAnchor.constraint(equalTo: windLabel.centerYAnchor),
            windSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            pressureLabel.topAnchor.constraint(equalTo: windLabel.bottomAnchor, constant: 24),
            pressureLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            pressureSegmentedControl.centerYAnchor.constraint(equalTo: pressureLabel.centerYAnchor),
            pressureSegmentedControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            tempSegmentedControl.widthAnchor.constraint(equalTo: pressureSegmentedControl.widthAnchor),
            windSegmentedControl.widthAnchor.constraint(equalTo: pressureSegmentedControl.widthAnchor)
        ])
        
        
    }
    
}

