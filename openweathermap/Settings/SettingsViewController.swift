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
    
    private lazy var apiKeyTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .colorBlack
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "API key".localized
        return label
    }()
    
    private lazy var apiKeyTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .colorWhite
        textView.sizeToFit()
        textView.isScrollEnabled = false
        
        let urlString = "https://home.openweathermap.org/api_keys"
        let attributedString = NSMutableAttributedString(string: "API text".localized + "API link".localized + ".")
        guard let url = URL(string: urlString) else { return textView }
        
        let fullRange = NSRange(location: 0, length: attributedString.length)
        let urlRange = NSRange(location: "API text".localized.count, length: "API link".localized.count)
        attributedString.addAttributes([.link: url], range: urlRange)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16), range: fullRange)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.colorBlack, range: fullRange)
        attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.colorWhite, range: fullRange)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .justified
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: fullRange)
        
        textView.attributedText = attributedString
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.colorBlack,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        return textView
    }()
    
    private lazy var apiKeyTextField: UITextField = {
        let inputView = UITextField()
        inputView.placeholder = "Enter your API key".localized
        inputView.backgroundColor = .colorGray
        inputView.layer.cornerRadius = 5
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        inputView.leftView = leftView
        inputView.leftViewMode = .always
        inputView.clipsToBounds = true
        inputView.clearButtonMode = .whileEditing
        inputView.text = SettingsVarible.shared.getApiKey()
        return inputView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if SettingsVarible.shared.getApiKey() != apiKeyTextField.text {
            Cache.shared.clearCache()
        }
        SettingsVarible.shared.setApiKey(apiKey: apiKeyTextField.text)
        super.viewWillDisappear(animated)
    }
    
    private func setupViews() {
        view.backgroundColor = .colorWhite
        
        [titleLabel, tempLabel, tempSegmentedControl, windLabel, windSegmentedControl, pressureLabel, pressureSegmentedControl, apiKeyTitleLabel, apiKeyTextView, apiKeyTextField].forEach {
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
            windSegmentedControl.widthAnchor.constraint(equalTo: pressureSegmentedControl.widthAnchor),
            apiKeyTitleLabel.topAnchor.constraint(equalTo: pressureSegmentedControl.bottomAnchor, constant: 16),
            apiKeyTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            apiKeyTextView.topAnchor.constraint(equalTo: apiKeyTitleLabel.bottomAnchor),
            apiKeyTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            apiKeyTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            apiKeyTextField.topAnchor.constraint(equalTo: apiKeyTextView.bottomAnchor, constant: 16),
            apiKeyTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            apiKeyTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            apiKeyTextField.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
}
